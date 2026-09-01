class PaymentApprover
  class Error < StandardError; end

  def self.call(payment:, admin_note: nil)
    new(payment:, admin_note:).call
  end

  def initialize(payment:, admin_note: nil)
    @payment = payment
    @admin_note = admin_note
  end

  def call
    raise Error, "อนุมัติไม่ได้ในสถานะนี้" unless payment.pending? && payment.order.payment_submitted?

    Order.transaction do
      payment.order.order_items.includes(:product_variant).each do |item|
        variant = item.product_variant
        raise Error, "#{variant.product.name} สต็อกไม่พอ" if variant.stock_quantity < item.quantity

        variant.decrement!(:stock_quantity, item.quantity)
      end

      payment.update!(status: :approved, admin_note: admin_note)
      payment.order.update!(status: :paid)
    end
  end

  private

  attr_reader :payment, :admin_note
end
