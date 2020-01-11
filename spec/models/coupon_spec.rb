require 'rails_helper'

RSpec.describe Coupon do
  describe "validations" do
    it {should validate_presence_of :name}
    # this could have a limited number of characters
    it {should validate_presence_of :code}
    it {should validate_presence_of :percent}
    #do you need to validate both presence of and numericality of?
    it {should validate_numericality_of :percent, greater_than_or_equal_to: 0}
    it {should validate_numericality_of :percent, less_than_or_equal_to: 1}
    it {should validate_uniqueness_of :name}
    it {should validate_uniqueness_of :code}
  end

  describe "relationships" do
    it {should belong_to :merchant}
    it {should belong_to(:order).optional}
  end
end
