class CheckoutCreator
  PAYMENT_WINDOW = 5.minutes

  class Error < StandardError; end

  def self.call(user:, params:)
    new(user:, params:).call
  end

  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    cart_items = user.cart_items.includes(product_variant: :product)
    raise Error, "ตะกร้าว่าง" if cart_items.empty?

    shipping = ShippingFeeCalculator.call(postal_code: params[:postal_code])
    subtotal = cart_items.sum(&:subtotal)
    deadline = PAYMENT_WINDOW.from_now

    has_preorder = cart_items.any? { |item| item.product_variant.is_preorder? }
    if has_preorder && !params[:preorder_acknowledged]
      raise Error, "กรุณายอมรับเงื่อนไขการพรีออเดอร์"
    end

    order = nil

    Order.transaction do
      cart_items.each do |item|
        variant = item.product_variant.lock!
        if variant.is_preorder?
          if !variant.preorder_available?
            raise Error, "#{variant.product.name} (#{variant.display_label}) พรีออเดอร์เต็มแล้ว"
          elsif variant.available_quantity < item.quantity
            raise Error, "#{variant.product.name} (#{variant.display_label}) โควต้าพรีออเดอร์ไม่พอ"
          end
        else
          if variant.available_quantity < item.quantity
            raise Error, "#{variant.product.name} (#{variant.display_label}) มีสต็อกไม่พอ"
          end
        end
      end

      order = user.orders.create!(
        status: :pending_payment,
        subtotal_amount: subtotal,
        shipping_fee: shipping[:shipping_fee],
        total_amount: subtotal + shipping[:shipping_fee],
        postal_code: shipping[:postal_code],
        shipping_zone: shipping[:zone],
        payment_deadline_at: deadline,
        recipient_name: params[:recipient_name],
        phone: params[:phone],
        address: params[:address]
      )

      cart_items.each do |item|
        variant = item.product_variant
        order.order_items.create!(
          product_variant: variant,
          quantity: item.quantity,
          unit_price: variant.price,
          is_preorder: variant.is_preorder?,
          preorder_status: variant.is_preorder? ? :pending_fulfillment : :fulfilled
        )
      end

      StockReservation.reserve!(order.order_items.includes(:product_variant))
      order.create_payment!(method: params[:payment_method], status: :pending)
      user.cart_items.destroy_all
    end

    OrderExpirationJob.set(wait_until: deadline).perform_later(order.id)
    order
  end

  private

  attr_reader :user, :params
end
