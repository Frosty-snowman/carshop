class Product < ApplicationRecord
  LOW_STOCK_THRESHOLD = 3

  belongs_to :category
  has_many :product_variants, dependent: :destroy
  has_one_attached :image

  validates :name, presence: true

  scope :in_stock, -> {
    joins(:product_variants)
      .where("product_variants.stock_quantity > product_variants.reserved_quantity")
      .distinct
  }
  scope :out_of_stock, -> { where.not(id: in_stock.select(:id)) }
  scope :sorted_by, ->(sort) {
    case sort
    when "price_asc"
      order(Arel.sql("(SELECT MIN(price) FROM product_variants WHERE product_variants.product_id = products.id) ASC NULLS LAST"))
    when "price_desc"
      order(Arel.sql("(SELECT MIN(price) FROM product_variants WHERE product_variants.product_id = products.id) DESC NULLS LAST"))
    else
      order(created_at: :desc)
    end
  }

  def available_variants
    product_variants.where("stock_quantity > reserved_quantity")
  end

  def min_price
    product_variants.minimum(:price)
  end

  def in_stock?
    available_variants.exists?
  end

  def total_available_stock
    product_variants.sum(Arel.sql("GREATEST(stock_quantity - reserved_quantity, 0)"))
  end

  def low_stock?
    in_stock? && total_available_stock <= LOW_STOCK_THRESHOLD
  end

  def deletable?
    !product_variants.joins(:order_items).exists?
  end
end
