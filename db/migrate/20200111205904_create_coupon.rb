class CreateCoupon < ActiveRecord::Migration[5.1]
  def change
    create_table :coupons do |t|
      t.string :name
      t.string :code
      t.numeric :percent, precision: 2, scale: 2
    end
  end
end
