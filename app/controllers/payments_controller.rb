class PaymentsController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_order

  def update
    unless @order.can_upload_slip?
      redirect_to order_path(@order), alert: "ไม่สามารถแนบสลิปในสถานะนี้"
      return
    end

    payment = @order.payment
    payment.assign_attributes(payment_params)
    payment.status = :pending

    if payment.save(context: :customer_submit)
      @order.update!(status: :payment_submitted)
      redirect_to order_path(@order), notice: "ส่งสลิปแล้ว รอแอดมินตรวจสอบ"
    else
      redirect_to order_path(@order), alert: payment.errors.full_messages.to_sentence
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:order_id])
  end

  def payment_params
    params.require(:payment).permit(:method, :slip)
  end
end
