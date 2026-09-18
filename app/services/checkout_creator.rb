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

    order = nil

    Order.transaction do
      cart_items.each do |item|
        variant = item.product_variant.lock!
        if variant.available_quantity < item.quantity
          raise Error, "#{variant.product.name} (#{variant.display_label}) มีสต็อกไม่พอ"
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
        order.order_items.create!(
          product_variant: item.product_variant,
          quantity: item.quantity,
          unit_price: item.product_variant.price
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
