class Order <ApplicationRecord
  validates_presence_of :name, :address, :city, :state, :zip, :status

  belongs_to :user
  belongs_to :coupon, optional: true

  has_many :item_orders
  has_many :items, through: :item_orders

  enum status: [:packaged, :pending, :shipped, :cancelled]

  def grandtotal
    item_orders.sum('price * quantity')
  end

  def discounted_total
    percent_discount = coupon.percent/100.to_f
    ids = items.where(merchant_id: coupon.merchant_id).pluck(:id)
    dollars_off = item_orders.where(item_id: ids).sum("price * quantity * #{percent_discount}")
    grandtotal - dollars_off
  end

  def total_items
    item_orders.sum('quantity')
  end

  def all_items_fulfilled?
    item_orders.count == item_orders.where(status: 'fulfilled').count
  end

  def update_order_status_to_packaged
    update(status: 0)
  end

  def self.order_by_status
    order(:status)
  end
end
