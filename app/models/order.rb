class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_one :payment, dependent: :destroy

  enum :status, {
    pending_payment: 0,
    payment_submitted: 1,
    paid: 2,
    shipped: 3,
    completed: 4,
    payment_rejected: 5,
    cancelled: 6
  }

  validates :recipient_name, :phone, :address, presence: true
  validates :tracking_number, presence: true, if: :shipped?

  scope :recent, -> { order(created_at: :desc) }

  def status_label
    {
      "pending_payment" => "รอชำระเงิน",
      "payment_submitted" => "รอตรวจสอบสลิป",
      "paid" => "ชำระแล้ว / รอจัดส่ง",
      "shipped" => "จัดส่งแล้ว",
      "completed" => "สำเร็จ",
      "payment_rejected" => "สลิปไม่ผ่าน",
      "cancelled" => "ยกเลิก"
    }[status]
  end

  def can_upload_slip?
    pending_payment? || payment_rejected?
  end

  def awaiting_admin_review?
    payment_submitted?
  end
end
