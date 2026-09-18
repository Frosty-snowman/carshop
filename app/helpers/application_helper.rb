module ApplicationHelper
  def format_baht(amount)
    number_to_currency(amount, unit: "฿", precision: 2, format: "%u%n")
  end

  CATEGORY_STYLES = {
    "Pokemon" => { emoji: "⚡", gradient: "from-yellow-500/20 to-amber-600/20", border: "border-yellow-500/30", text: "text-yellow-400" },
    "Yu-Gi-Oh!" => { emoji: "🐉", gradient: "from-blue-500/20 to-indigo-600/20", border: "border-blue-500/30", text: "text-blue-400" },
    "One Piece" => { emoji: "🏴‍☠️", gradient: "from-red-500/20 to-orange-600/20", border: "border-red-500/30", text: "text-red-400" }
  }.freeze

  def category_style(category)
    CATEGORY_STYLES.fetch(category.name, { emoji: "🃏", gradient: "from-violet-500/20 to-purple-600/20", border: "border-violet-500/30", text: "text-violet-400" })
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
