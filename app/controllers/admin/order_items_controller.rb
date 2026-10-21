module Admin
  class OrderItemsController < BaseController
    before_action :set_order_item

    def update
      if @order_item.update(order_item_params)
        redirect_to admin_order_path(@order_item.order), notice: "อัปเดตสถานะพรีออเดอร์แล้ว"
      else
        redirect_to admin_order_path(@order_item.order), alert: "ไม่สามารถอัปเดตได้"
      end
    end

    private

    def set_order_item
      @order_item = OrderItem.find(params[:id])
    end

    def order_item_params
      params.permit(:preorder_status)
    end
  end
end
