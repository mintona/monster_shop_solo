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
    # item_orders = self.item_orders
    # items_matching_coupon_merchant = items.where(merchant_id: coupon.merchant_id)
    ids = items.where(merchant_id: coupon.merchant_id).pluck(:id)
    multiplier = (100 - coupon.percent)/100.to_f
    # item_orders_with_discounted_items = item_orders.where(item_id: ids)
    # regular_total = item_orders_with_discounted_items.sum('price * quantity')
    regular_total = item_orders.where(item_id: ids).sum('price * quantity')
    discounted_total = regular_total * multiplier

    dollars_off = regular_total - discounted_total
    # discounted_total = item_orders.where(item_id: ids).sum('price * quantity') * multiplier
    # grandtotal - discounted_total
    grandtotal - dollars_off
    # require "pry"; binding.pry

# require "pry"; binding.pry
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
