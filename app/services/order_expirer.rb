class OrderExpirer
  def self.expire!(order)
    new(order).expire!
  end

  def self.expire_due_orders!
    Order.where(status: %i[pending_payment payment_rejected])
      .where("payment_deadline_at <= ?", Time.current)
      .find_each { |order| expire!(order) }
  end

  def initialize(order)
    @order = order
  end

  def expire!
    return false unless order.pending_payment? || order.payment_rejected?
    return false if order.payment_deadline_at.blank?
    return false if order.payment_deadline_at > Time.current

    Order.transaction do
      StockReservation.release!(order.order_items.includes(:product_variant))
      order.update!(status: :cancelled)
    end

    true
  end

  private

  attr_reader :order
end
