require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < ActiveSupport::TestCase
#  fixtures :orders
  
  def test_editable_ACTIVE_by_owner
    order = Order.find(1)
    user = User.find_by_login("user")
    assert order.editable_by?(user), true
  end
  private
  
#  def create_order(options={})
#    defaults = {:name => "New Order", :description  => "Desc of the new order", :term => Date.today+5+i}
#    defaults.merge(options)
#    order = Order.new(defaults)
#    order.user_id     = data[0]
#    order.cost        = 5+i
#    order.privacy     = data[3] unless data[3].nil?
#    order.status      = data[4] unless data[4].nil?
#    order.save(false)
#      (rand(2)+1).times{Categorization.create!(:category => Category.find(rand(Category.count-1)+1), :order => order)}
#
#  end
end
