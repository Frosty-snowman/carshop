module Admin
  class CategoriesController < BaseController
    before_action :set_category, only: %i[edit update destroy]

    def index
      @categories = Category.all
    end

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)
      if @category.save
        redirect_to admin_categories_path, notice: "สร้างหมวดหมู่แล้ว"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @category.update(category_params)
        redirect_to admin_categories_path, notice: "อัปเดตหมวดหมู่แล้ว"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @category.products.any?
        redirect_to admin_categories_path, alert: "ลบไม่ได้ มีสินค้าในหมวดหมู่นี้"
      else
        @category.destroy
        redirect_to admin_categories_path, notice: "ลบหมวดหมู่แล้ว"
      end
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :description, :position)
    end
  end
end
