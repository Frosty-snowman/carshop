class ProductsController < ApplicationController
  def index
    @categories = Category.all
    @products = Product.includes(:category, :product_variants, image_attachment: :blob)
    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?

    @products = case params[:stock]
    when "in_stock" then @products.in_stock
    when "out_of_stock" then @products.out_of_stock
    else @products
    end

    @products = @products.sorted_by(params[:sort])
  end

  def show
    @product = Product.includes(:category, :product_variants).find(params[:id])
  end
end
