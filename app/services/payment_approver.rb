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
    approvable = payment.pending? && (payment.order.payment_submitted? || payment.order.pending_payment?)
    raise Error, "อนุมัติไม่ได้ในสถานะนี้" unless approvable

    Order.transaction do
      StockReservation.fulfill!(payment.order.order_items.includes(:product_variant))

      payment.update!(status: :approved, admin_note: admin_note)
      payment.order.update!(status: :paid)
    end
  end

  private

  attr_reader :payment, :admin_note
end
