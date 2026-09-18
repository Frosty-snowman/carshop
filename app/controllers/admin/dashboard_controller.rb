module Admin
  class DashboardController < BaseController
    def show
      @sales = SalesSummary.new
      @pending_payments = Payment.pending.includes(order: :user).joins(:order).where(orders: { status: :payment_submitted })
      @paid_orders = Order.paid.recent.limit(5)
      @low_stock_variants = ProductVariant.where("stock_quantity <= 3").includes(product: :category).order(:stock_quantity).limit(5)
      @daily_revenue = @sales.daily_revenue
      @max_daily = @daily_revenue.map { |d| d[:amount].to_f }.max
      @max_daily = 1 if @max_daily.zero?
    end
  end
end
