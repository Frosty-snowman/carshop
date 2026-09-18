class OrderExpirationSweepJob < ApplicationJob
  queue_as :default

  def perform
    OrderExpirer.expire_due_orders!
  end
end
