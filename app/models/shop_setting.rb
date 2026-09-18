class ShopSetting < ApplicationRecord
  has_one_attached :qr_code

  validate :qr_code_content_type, if: -> { qr_code.attached? }

  def self.current
    first_or_create!
  end

  private

  def qr_code_content_type
    return if qr_code.content_type.in?(%w[image/jpeg image/png image/webp])

    errors.add(:qr_code, "ต้องเป็น JPG, PNG หรือ WEBP")
  end
end
