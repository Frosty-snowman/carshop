class Product < ApplicationRecord
  belongs_to :category
  has_many :product_variants, dependent: :destroy
  has_one_attached :image

  validates :name, presence: true

  scope :in_stock, -> {
    joins(:product_variants)
      .where("product_variants.stock_quantity > product_variants.reserved_quantity")
      .distinct
  }

  def available_variants
    product_variants.where("stock_quantity > reserved_quantity")
  end

  def min_price
    product_variants.minimum(:price)
  end
end
