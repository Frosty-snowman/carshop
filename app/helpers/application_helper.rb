module ApplicationHelper
  def format_baht(amount)
    number_to_currency(amount, unit: "฿", precision: 2, format: "%u%n")
  end

  def order_status_badge_class(status)
    {
      "pending_payment" => "bg-yellow-100 text-yellow-800",
      "payment_submitted" => "bg-blue-100 text-blue-800",
      "paid" => "bg-green-100 text-green-800",
      "shipped" => "bg-indigo-100 text-indigo-800",
      "completed" => "bg-gray-100 text-gray-800",
      "payment_rejected" => "bg-red-100 text-red-800",
      "cancelled" => "bg-gray-100 text-gray-600"
    }[status] || "bg-gray-100 text-gray-800"
  end
end
