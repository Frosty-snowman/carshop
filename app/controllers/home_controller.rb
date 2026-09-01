class HomeController < ApplicationController
  def index
    @categories = Category.includes(:products)
    @products = Product.includes(:category, :product_variants, image_attachment: :blob)
                       .in_stock
                       .order(created_at: :desc)
                       .limit(12)
  end
end
