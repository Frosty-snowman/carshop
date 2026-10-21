class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_error

  enum :condition, { new_condition: 0, used: 1 }, prefix: :condition
  enum :language, { th: 0, en: 1, ja: 2 }

  LANGUAGE_LABELS = {
    "th" => "ภาษาไทย",
    "en" => "En",
    "ja" => "Jp"
  }.freeze

  def self.language_options
    languages.keys.map { |key| [ LANGUAGE_LABELS[key], key ] }
  end

  validates :price, numericality: { greater_than: 0 }
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :reserved_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :preorder_quota, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: :is_preorder?
  validates :preorder_reserved, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, if: :is_preorder?
  validate :reserved_not_exceed_stock
  validate :preorder_reserved_not_exceed_quota
  validate :preorder_requires_release_date
  validates :condition, uniqueness: { scope: %i[product_id language] }

  def available_quantity
    if is_preorder?
      preorder_quota - preorder_reserved
    else
      stock_quantity - reserved_quantity
    end
  end

  def in_stock?
    available_quantity.positive?
  end

  def preorder_available?
    return false unless is_preorder?
    return false if preorder_closes_at.present? && preorder_closes_at < Time.current

    available_quantity.positive?
  end

  def replenish!(amount)
    amount = amount.to_i
    raise ArgumentError, "amount must be positive" if amount <= 0

    increment!(:stock_quantity, amount)
  end

  def display_label
    "#{condition_label} / #{language_label}"
  end

  def condition_label
    condition_new_condition? ? "สภาพใหม่" : "สภาพใช้งานแล้ว"
  end

  def language_label
    LANGUAGE_LABELS[language]
  end

  def subtotal_for(quantity)
    price * quantity
  end

  private

  def reserved_not_exceed_stock
    return if is_preorder?
    return if reserved_quantity <= stock_quantity

    errors.add(:reserved_quantity, "ต้องไม่เกินจำนวนสต็อก")
  end

  def preorder_reserved_not_exceed_quota
    return unless is_preorder?
    return if preorder_reserved <= preorder_quota

    errors.add(:preorder_reserved, "ต้องไม่เกินโควต้าพรีออเดอร์")
  end

  def preorder_requires_release_date
    return unless is_preorder?
    return if preorder_release_date.present?

    errors.add(:preorder_release_date, "ต้องระบุวันที่วางจำหน่าย")
  end
end
