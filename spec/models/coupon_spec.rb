require 'rails_helper'

RSpec.describe Coupon do
  describe "validations" do
    it {should validate_presence_of :name}
    it {should validate_uniqueness_of :name}
    # this could have a limited number of characters
    it {should validate_presence_of :code}
    it {should validate_uniqueness_of :code}

    it {should validate_presence_of :percent}
    #do you need to validate both presence of and numericality of?
    it {should validate_numericality_of(:percent).is_greater_than_or_equal_to(0)}
    it {should validate_numericality_of(:percent).is_less_than_or_equal_to(100)}

  end

  describe "relationships" do
    it {should belong_to :merchant}
    # it {should belong_to(:order).optional}
    it {should have_many :orders}
  end
end
