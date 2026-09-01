class ProductsController < ApplicationController
  def index
    @categories = Category.all
    @products = Product.includes(:category, :product_variants, image_attachment: :blob).order(created_at: :desc)
    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?
    @products = @products.in_stock if params[:in_stock] == "1"
  end

  def show
    @product = Product.includes(:category, :product_variants).find(params[:id])
  end
end
