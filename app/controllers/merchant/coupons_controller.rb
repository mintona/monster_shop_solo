class Merchant::CouponsController < Merchant::BaseController
  def index
    @coupons = Coupon.where(merchant_id: current_user.merchant_id)
  end

  def show
    @coupon = Coupon.find(params[:id])
  end

  def new
    @coupon = Coupon.new
  end

  private
    def coupon_params
      params.require(:coupon).permit(:name, :code, :percent)
    end
end
