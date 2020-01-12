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

  def create
    merchant = Merchant.find(current_user.merchant_id)
    @coupon = merchant.coupons.new(coupon_params)

    if @coupon.save
      flash[:success] = "Coupon has been added!"
      redirect_to merchant_coupons_path
    else
      flash[:error] = "#{@coupon.errors.full_messages.to_sentence}. Please try again."
      render :new
    end
  end

  def edit
    @coupon = Coupon.find(params[:id])
  end

  private
    def coupon_params
      params.require(:coupon).permit(:name, :code, :percent)
    end
end
