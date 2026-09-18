class OrderExpirationJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find_by(id: order_id)
    return unless order

    OrderExpirer.expire!(order)
  end
end
