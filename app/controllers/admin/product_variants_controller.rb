module Admin
  class ProductVariantsController < BaseController
    before_action :set_product
    before_action :set_variant, only: %i[edit update destroy replenish]

    def new
      @variant = @product.product_variants.build
    end

    def create
      @variant = @product.product_variants.build(variant_params)
      if @variant.save
        redirect_to admin_product_path(@product), notice: "เพิ่ม variant แล้ว"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @variant.update(variant_params)
        redirect_to admin_product_path(@product), notice: "อัปเดต variant แล้ว"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @variant.destroy
      redirect_to admin_product_path(@product), notice: "ลบ variant แล้ว"
    end

    def replenish
      @variant.replenish!(params[:amount])
      redirect_to admin_product_path(@product), notice: "เติมสต็อก #{params[:amount]} ใบแล้ว (รวม #{@variant.stock_quantity} ใบ)"
    rescue ArgumentError
      redirect_to admin_product_path(@product), alert: "จำนวนต้องมากกว่า 0"
    end

    private

    def set_product
      @product = Product.find(params[:product_id])
    end

    def set_variant
      @variant = @product.product_variants.find(params[:id])
    end

    def variant_params
      params.require(:product_variant).permit(:condition, :language, :price, :stock_quantity)
    end
  end
end
