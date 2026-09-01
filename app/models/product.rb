class Product < ApplicationRecord
  belongs_to :category
  has_many :product_variants, dependent: :destroy
  has_one_attached :image

  validates :name, presence: true

  scope :in_stock, -> { joins(:product_variants).where("product_variants.stock_quantity > 0").distinct }

  def available_variants
    product_variants.where("stock_quantity > 0")
  end

  def min_price
    product_variants.minimum(:price)
  end
end
