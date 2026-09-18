class FeatureRequestsController < ApplicationController
  def new
    @feature_request = FeatureRequest.new(
      name: current_user&.name,
      email: current_user&.email
    )
  end

  def create
    @feature_request = FeatureRequest.new(feature_request_params)
    @feature_request.user = current_user if user_signed_in?

    if @feature_request.save
      redirect_to root_path, notice: "ส่งคำร้องแล้ว ขอบคุณที่แนะนำ!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def feature_request_params
    params.require(:feature_request).permit(:name, :email, :title, :description)
  end
end
