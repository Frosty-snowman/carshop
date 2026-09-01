class OrdersController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_order, only: %i[show]

  def index
    @orders = current_user.orders.recent.includes(:payment)
  end

  def show
    @shop_setting = ShopSetting.current
  end

  private

  def set_order
    @order = current_user.orders.includes(order_items: { product_variant: :product }, payment: { slip_attachment: :blob }).find(params[:id])
  end
end
