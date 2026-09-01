class Payment < ApplicationRecord
  belongs_to :order
  has_one_attached :slip

  enum :method, { bank_transfer: 0, qr: 1 }
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  validates :slip, presence: true, on: :customer_submit
  validate :slip_content_type, if: -> { slip.attached? }

  def method_label
    bank_transfer? ? "โอนบัญชี" : "QR Code"
  end

  def status_label
    { "pending" => "รอตรวจสอบ", "approved" => "อนุมัติแล้ว", "rejected" => "ปฏิเสธ" }[status]
  end

  private

  def slip_content_type
    return if slip.content_type.in?(%w[image/jpeg image/png image/webp application/pdf])

    errors.add(:slip, "ต้องเป็นไฟล์ JPG, PNG, WEBP หรือ PDF")
  end
end
