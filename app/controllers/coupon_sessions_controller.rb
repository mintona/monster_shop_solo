class CouponSessionsController < ApplicationController
  def create
    coupon = Coupon.find_by(code: params[:code])
    if coupon.nil?
      flash[:error] = "The coupon code you have entered does not exist. Please try again."
    else
      items = Item.where(id: cart.contents.keys)
      attempt_to_apply_coupon(coupon, items)
    end
    redirect_to cart_path
  end

  private
    def attempt_to_apply_coupon(coupon, items)
      if items.where(merchant_id: coupon.merchant_id).any?
        session[:coupon_id] = coupon.id
        flash[:success] = "#{coupon.code} has been applied to your cart."
      else
        flash[:error] = "Coupon cannot be applied to your items. Please add items from #{coupon.merchant.name} and re-enter code or try another code."
      end
    end
end
