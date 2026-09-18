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

  enum :shipping_carrier, { flash: 0, kerry: 1, thailand_post: 2, other: 3 }, prefix: :carrier

  TRACKING_URLS = {
    "flash" => "https://www.flashexpress.co.th/tracking/?se=",
    "kerry" => "https://th.kerryexpress.com/th/track/?track=",
    "thailand_post" => "https://track.thailandpost.co.th/?trackNumber="
  }.freeze

  PAYMENT_WINDOW_MINUTES = 5

  validates :recipient_name, :phone, :address, presence: true
  validates :postal_code, format: { with: /\A\d{5}\z/, message: "ต้องเป็น 5 หลัก" }, allow_blank: true
  validates :tracking_number, :shipping_carrier, presence: true, if: :shipped?

  scope :recent, -> { order(created_at: :desc) }

  def expire_if_needed!
    OrderExpirer.expire!(self)
  end

  def payment_expired?
    pending_payment? && payment_deadline_at.present? && payment_deadline_at <= Time.current
  end

  def payment_time_remaining
    return 0.seconds if payment_deadline_at.blank?

    [ payment_deadline_at - Time.current, 0.seconds ].max
  end

  def shipping_zone_label
    ShippingFeeCalculator.zone_label(shipping_zone)
  end

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

  def carrier_label
    {
      "flash" => "Flash Express",
      "kerry" => "Kerry Express",
      "thailand_post" => "ไปรษณีย์ไทย",
      "other" => "อื่นๆ"
    }[shipping_carrier]
  end

  def tracking_url
    return if tracking_number.blank? || shipping_carrier.blank?
    return if carrier_other?

    base = TRACKING_URLS[shipping_carrier]
    return unless base

    "#{base}#{CGI.escape(tracking_number)}"
  end

  def can_upload_slip?
    return false if cancelled?
    return false unless pending_payment? || payment_rejected?
    return true if payment_deadline_at.blank?

    payment_deadline_at > Time.current
  end

  def awaiting_admin_review?
    payment_submitted?
  end

  TIMELINE_KEYS = %i[ordered payment review preparing shipped completed].freeze

  def timeline_steps
    meta = [
      { key: :ordered, icon: "🛒", label: "สั่งซื้อ", desc: "ได้รับคำสั่งซื้อแล้ว" },
      { key: :payment, icon: "💳", label: "ชำระเงิน", desc: "โอนเงินและแนบสลิป" },
      { key: :review, icon: "🔍", label: "ตรวจสอบ", desc: "ร้านกำลังตรวจสอบสลิป" },
      { key: :preparing, icon: "📦", label: "เตรียมจัดส่ง", desc: "กำลังแพ็คสินค้า" },
      { key: :shipped, icon: "🚚", label: "จัดส่งแล้ว", desc: "สินค้าออกจากร้านแล้ว" },
      { key: :completed, icon: "✅", label: "สำเร็จ", desc: "ได้รับสินค้าเรียบร้อย" }
    ]

    current_index = TIMELINE_KEYS.index(timeline_current_key) || 0

    meta.map.with_index do |step, index|
      state =
        if payment_rejected? && step[:key] == :review
          :failed
        elsif cancelled?
          index.zero? ? :done : :pending
        elsif index < current_index
          :done
        elsif index == current_index
          :current
        else
          :pending
        end

      { **step, state: state, current: state == :current }
    end
  end

  private

  def timeline_current_key
    return :ordered if pending_payment?
    return :review if payment_submitted? || payment_rejected?
    return :preparing if paid?
    return :shipped if shipped?
    return :completed if completed?

    :ordered
  end
end
