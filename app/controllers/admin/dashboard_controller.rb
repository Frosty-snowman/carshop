module Admin
  class DashboardController < BaseController
    def show
      @pending_payments = Payment.pending.includes(order: :user).joins(:order).where(orders: { status: :payment_submitted })
      @paid_orders = Order.paid.recent.limit(10)
      @low_stock_variants = ProductVariant.where("stock_quantity <= 3").includes(product: :category).order(:stock_quantity)
    end
  end
end
