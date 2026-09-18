class CartItemsController < ApplicationController
  before_action :authenticate_customer!

  def index
    @cart_items = current_cart_items
  end

  def create
    variant = ProductVariant.find(params[:product_variant_id])
    item = current_user.cart_items.find_or_initialize_by(product_variant: variant)
    item.quantity = item.persisted? ? item.quantity + quantity_param : quantity_param

    if item.quantity > variant.stock_quantity
      redirect_to product_path(variant.product), alert: "สต็อกไม่พอ (เหลือ #{variant.stock_quantity} ใบ)"
    elsif item.save
      redirect_to cart_items_path, notice: "เพิ่มลงตะกร้าแล้ว"
    else
      redirect_to product_path(variant.product), alert: item.errors.full_messages.to_sentence
    end
  end

  def update
    item = current_user.cart_items.find(params[:id])
    if item.update(quantity: quantity_param)
      redirect_to cart_items_path, notice: "อัปเดตตะกร้าแล้ว"
    else
      redirect_to cart_items_path, alert: item.errors.full_messages.to_sentence
    end
  end

  def destroy
    current_user.cart_items.find(params[:id]).destroy
    redirect_to cart_items_path, notice: "ลบออกจากตะกร้าแล้ว"
  end

  private

  def quantity_param
    [ params.fetch(:quantity, 1).to_i, 1 ].max
  end
end
