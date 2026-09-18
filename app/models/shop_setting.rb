class ShopSetting < ApplicationRecord
  has_one_attached :qr_code

  validate :qr_code_must_be_image, if: -> { qr_code.attached? }

  def self.current
    first_or_create!
  end

  private

  def qr_code_must_be_image
    blob = qr_code.blob
    return if blob.blank?

    type = blob.content_type.to_s
    return if type.start_with?("image/")

    errors.add(:qr_code, "ต้องเป็นไฟล์รูปภาพ (JPG, PNG, WEBP, HEIC) — ถ้าเป็นรูปจาก iPhone ให้ลองแปลงเป็น JPG ก่อน")
  end
end
