class ChangePercentOnCoupons < ActiveRecord::Migration[5.1]
  def change
    change_column :coupons, :percent, :integer
  end
end
