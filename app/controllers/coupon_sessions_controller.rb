class CouponSessionsController < ApplicationController
  def create
    coupon = Coupon.find_by(code: params[:code])

    if coupon.nil?
      flash[:error] = "The coupon code you have entered does not exist. Please try again."
    else
      item_ids = cart.contents.keys
      items = Item.find(item_ids)
      if items.any? { |item| item.merchant_id == coupon.merchant_id }
        session[:coupon_id] = coupon.id
        flash[:success] = "#{coupon.code} has been applied to your cart."
      else
        flash[:error] = "Coupon cannot be applied to your items. Please add items from #{coupon.merchant.name} and re-enter code or try another code."
      end
    end
    redirect_to cart_path
  end
end
