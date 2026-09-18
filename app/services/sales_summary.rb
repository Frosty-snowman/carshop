class SalesSummary
  REVENUE_STATUSES = %i[paid shipped completed].freeze

  def total_revenue(period: :month)
    revenue_scope(period).sum(:total_amount)
  end

  def order_count(period: :month)
    revenue_scope(period).count
  end

  def unique_customers(period: :month)
    revenue_scope(period).distinct.count(:user_id)
  end

  def pending_slip_count
    Order.payment_submitted.count
  end

  def awaiting_shipment_count
    Order.paid.count
  end

  def top_products(limit: 5)
    OrderItem
      .joins(:order, product_variant: :product)
      .where(orders: { status: REVENUE_STATUSES })
      .group("products.name")
      .order(Arel.sql("SUM(order_items.quantity) DESC"))
      .limit(limit)
      .sum("order_items.quantity")
  end

  def revenue_by_category
    OrderItem
      .joins(:order, product_variant: { product: :category })
      .where(orders: { status: REVENUE_STATUSES })
      .group("categories.name")
      .sum(Arel.sql("order_items.quantity * order_items.unit_price"))
  end

  def daily_revenue(days: 7)
    days.times.map do |i|
      date = (days - 1 - i).days.ago.to_date
      {
        date: date,
        label: I18n.l(date, format: "%a %d/%m"),
        amount: revenue_scope(:all).where(created_at: date.all_day).sum(:total_amount)
      }
    end
  end

  def recent_orders(limit: 5)
    Order.includes(:user).recent.limit(limit)
  end

  private

  def revenue_scope(period)
    scope = Order.where(status: REVENUE_STATUSES)
    return scope.where(created_at: Time.current.all_month) if period == :month

    scope
  end
end
