class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_cart_items, :cart_total, :cart_count

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name])
  end

  def authenticate_customer!
    authenticate_user!
    return if current_user.customer?

    redirect_to root_path, alert: "บัญชีนี้ไม่สามารถสั่งซื้อได้"
  end

  def require_admin!
    authenticate_user!
    return if current_user.admin?

    redirect_to root_path, alert: "ไม่มีสิทธิ์เข้าถึง"
  end

  def current_cart_items
    return CartItem.none unless user_signed_in?

    current_user.cart_items.includes(product_variant: { product: :category })
  end

  def cart_total
    current_cart_items.sum(&:subtotal)
  end

  def cart_count
    current_cart_items.sum(:quantity)
  end
end
