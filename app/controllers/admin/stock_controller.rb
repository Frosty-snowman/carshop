module Admin
  class StockController < BaseController
    def index
      @categories = Category.all
      category_id = params[:category_id].presence || @categories.first&.id
      @selected_category = Category.find_by(id: category_id)
      @variants = ProductVariant.includes(product: :category).joins(:product).order("products.name", :condition, :language)
      @variants = @variants.where(products: { category_id: category_id }) if category_id.present?
    end

    def update
      category_id = params[:category_id]
      (params[:replenishments] || {}).each do |variant_id, amount|
        next if amount.to_i <= 0

        ProductVariant.find(variant_id).replenish!(amount)
      end

      redirect_to admin_stock_path(category_id: category_id), notice: "เติมสต็อกแล้ว"
    end
  end
end
