class CouponSessionsController < ApplicationController
  def create
    coupon = Coupon.find_by(code: params[:code])

    if coupon.nil?
      #message about invalid code
    else
      session[:coupon_id] = coupon.id
      flash[:success] = "#{coupon.code} has been applied to your order."
    end
    redirect_to cart_path
  end
end
