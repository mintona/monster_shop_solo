class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :orders

  validates :name, uniqueness: true, presence: true
  validates :code, uniqueness: true, presence: true
  validates_presence_of :percent

  validates_numericality_of :percent, greater_than: 0
  validates_numericality_of :percent, less_than_or_equal_to: 100

  def never_applied?
    orders.empty?
  end

  def deactivate
    update(active?: false)
  end

  def activate
    update(active?: true)
  end

  def status
    return "Active" if active? == true
    return "Inactive" if active? == false
  end
end
