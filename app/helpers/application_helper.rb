module ApplicationHelper
  def format_baht(amount)
    number_to_currency(amount, unit: "฿", precision: 2, format: "%u%n")
  end

  CATEGORY_STYLES = {
    "Pokemon" => { emoji: "⚡", gradient: "from-yellow-500/20 to-amber-600/20", border: "border-yellow-500/30", text: "text-yellow-400" },
    "Yu-Gi-Oh!" => { emoji: "🐉", gradient: "from-blue-500/20 to-indigo-600/20", border: "border-blue-500/30", text: "text-blue-400" },
    "One Piece" => { emoji: "🏴‍☠️", gradient: "from-red-500/20 to-orange-600/20", border: "border-red-500/30", text: "text-red-400" }
  }.freeze

  def products_filter_params(overrides = {})
    params.permit(:category_id, :stock, :sort).to_h.symbolize_keys.merge(overrides).compact_blank
  end

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

  def order_status_pill_class(status)
    {
      "pending_payment" => "bg-amber-500/20 text-amber-300 border-amber-500/30",
      "payment_submitted" => "bg-blue-500/20 text-blue-300 border-blue-500/30",
      "paid" => "bg-emerald-500/20 text-emerald-300 border-emerald-500/30",
      "shipped" => "bg-violet-500/20 text-violet-300 border-violet-500/30",
      "completed" => "bg-white/10 text-white/50 border-white/20",
      "payment_rejected" => "bg-red-500/20 text-red-300 border-red-500/30",
      "cancelled" => "bg-red-500/10 text-red-400/70 border-red-500/20"
    }[status] || "bg-white/10 text-white/50 border-white/20"
  end

  def order_action_hint(order)
    return "โอนเงินและแนบสลิป →" if order.pending_payment?
    return "แนบสลิปใหม่ →" if order.payment_rejected? && order.can_upload_slip?
    return "รอร้านตรวจสอบสลิป" if order.payment_submitted?
    return "ติดตามพัสดุ →" if order.shipped?
    return "ดูรายละเอียด →" if order.paid? || order.completed?

    "ดูรายละเอียด →"
  end
end
