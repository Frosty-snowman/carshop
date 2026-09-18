module Admin
  module OrdersHelper
    def order_admin_action_hint(order)
      {
        "pending_payment" => "รอสลิป",
        "payment_submitted" => "⚡ ตรวจสลิป",
        "paid" => "📦 กรอกเลขพัสดุ",
        "shipped" => "ปิดออเดอร์",
        "completed" => "—",
        "payment_rejected" => "รอสลิปใหม่",
        "cancelled" => "—"
      }[order.status]
    end

    def order_admin_action_class(order)
      {
        "payment_submitted" => "text-amber-700 font-bold",
        "paid" => "text-violet-700 font-bold",
        "shipped" => "text-indigo-700 font-medium",
        "pending_payment" => "text-yellow-700"
      }[order.status] || "text-slate-500"
    end
  end
end
