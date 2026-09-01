class CheckoutsController < ApplicationController
  before_action :authenticate_customer!
  before_action :ensure_cart_not_empty

  def new
    @cart_items = current_cart_items
    @shop_setting = ShopSetting.current
  end

  def create
    order = CheckoutCreator.call(user: current_user, params: checkout_params)
    redirect_to order_path(order), notice: "สร้างคำสั่งซื้อแล้ว กรุณาแนบสลิปเพื่อชำระเงิน"
  rescue CheckoutCreator::Error => e
    redirect_to cart_items_path, alert: e.message
  end

  private

  def ensure_cart_not_empty
    return unless current_cart_items.empty?

    redirect_to products_path, alert: "ตะกร้าว่าง"
  end

  def checkout_params
    params.require(:checkout).permit(:recipient_name, :phone, :address, :payment_method)
  end
end
