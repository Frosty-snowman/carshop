class CheckoutCreator
  class Error < StandardError; end

  def self.call(user:, params:)
    new(user:, params:).call
  end

  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    cart_items = user.cart_items.includes(:product_variant)
    raise Error, "ตะกร้าว่าง" if cart_items.empty?

    cart_items.each do |item|
      raise Error, "#{item.product_variant.product.name} มีสต็อกไม่พอ" if item.quantity > item.product_variant.stock_quantity
    end

    Order.transaction do
      order = user.orders.create!(
        status: :pending_payment,
        total_amount: cart_items.sum(&:subtotal),
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

      order.create_payment!(method: params[:payment_method], status: :pending)
      user.cart_items.destroy_all
      order
    end
  end

  private

  attr_reader :user, :params
end
