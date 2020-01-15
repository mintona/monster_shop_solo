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

    if merchant.less_than_five_coupons?
      attempt_coupon_creation(@coupon)
    else
      flash[:error] = "You already have 5 coupons. You must delete a coupon and try again."
      render :new
    end
  end

  def edit
    @coupon = Coupon.find(params[:id])
  end

  def update
    if info_update?
      @coupon = Coupon.find(params[:format])
      attempt_info_update(@coupon)
    else
      @coupon = Coupon.find(params[:id])
      update_status(@coupon)
    end
  end

  def destroy
    Coupon.destroy(params[:id])
    flash[:success] = "Coupon has been deleted."

    redirect_to merchant_coupons_path
  end

  private
    def coupon_params
      params.require(:coupon).permit(:name, :code, :percent)
    end

    def attempt_coupon_creation(coupon)
      if coupon.save
        flash[:success] = "Coupon has been added!"
        redirect_to merchant_coupons_path
      else
        flash[:error] = "#{@coupon.errors.full_messages.to_sentence}. Please try again."
        render :new
      end
    end

    def info_update?
      params[:status].nil?
    end

    def attempt_info_update(coupon)
      if coupon.update(coupon_params)
        flash[:success] = "Coupon has been updated!"
        redirect_to merchant_coupons_path
      else
        flash[:error] = "#{coupon.errors.full_messages.to_sentence}. Please try again."
        render :edit
      end
    end

    def update_status(coupon)
      if params[:status] = "deactivate"
        coupon.toggle!(:active?)
      else
        coupon.toggle!(:active?)
      end
      redirect_to merchant_coupons_path
    end
end
