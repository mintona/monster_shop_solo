class Merchant::CouponsController < Merchant::BaseController
  def index
    @coupons = Coupon.where(merchant_id: current_user.merchant_id)
  end

  def show
    @coupon = Coupon.find(params[:id])
  end
end
