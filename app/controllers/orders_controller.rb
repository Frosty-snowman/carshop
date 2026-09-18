class OrdersController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_order, only: %i[show]

  def index
    current_user.orders.pending_payment.where.not(payment_deadline_at: nil).find_each(&:expire_if_needed!)
    @orders = current_user.orders.recent.includes(:payment, order_items: { product_variant: :product })
  end

  def show
    @order.expire_if_needed!
    @order.reload
    @shop_setting = ShopSetting.current
  end

  private

  def set_order
    @order = current_user.orders.includes(order_items: { product_variant: :product }, payment: { slip_attachment: :blob }).find(params[:id])
  end
end
