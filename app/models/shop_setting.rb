class ShopSetting < ApplicationRecord
  has_one_attached :qr_code

  def self.current
    first_or_create!
  end
end
