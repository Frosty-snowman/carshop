module Admin
  class ProductsController < BaseController
    before_action :set_product, only: %i[show edit update destroy]

    def index
      @products = Product.includes(:category, :product_variants).order(created_at: :desc)
    end

    def show; end

    def new
      @product = Product.new
      @categories = Category.all
    end

    def create
      @product = Product.new(product_params)
      @categories = Category.all
      if @product.save
        redirect_to admin_product_path(@product), notice: "สร้างการ์ดแล้ว"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @categories = Category.all
    end

    def update
      @categories = Category.all
      if @product.update(product_params)
        redirect_to admin_product_path(@product), notice: "อัปเดตการ์ดแล้ว"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: "ลบการ์ดแล้ว"
    end

    private

    def set_product
      @product = Product.includes(:product_variants, image_attachment: :blob).find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :description, :category_id, :image)
    end
  end
end
