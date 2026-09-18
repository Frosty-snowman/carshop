module Admin
  class OrdersController < BaseController
    before_action :set_order, only: %i[show update]

    def index
      @orders = Order.includes(:user, :payment).recent
      @orders = @orders.where(status: params[:status]) if params[:status].present?
    end

    def show
      @shop_setting = ShopSetting.current
    end

    def update
      if params[:tracking_number].present?
        @order.update!(
          tracking_number: params[:tracking_number],
          shipping_carrier: params[:shipping_carrier],
          status: :shipped,
          shipped_at: Time.current
        )
        redirect_to admin_order_path(@order), notice: "บันทึกเลขพัสดุแล้ว"
      elsif params[:mark_completed].present?
        @order.update!(status: :completed)
        redirect_to admin_order_path(@order), notice: "ปิดออเดอร์สำเร็จ"
      else
        redirect_to admin_order_path(@order), alert: "ไม่มีการเปลี่ยนแปลง"
      end
    end

    private

    def set_order
      @order = Order.includes(:user, :payment, order_items: { product_variant: :product }).find(params[:id])
    end
  end
end
