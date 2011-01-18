class Category < ActiveRecord::Base
  validates_uniqueness_of :name
  has_many :categorizations
  has_many :orders, :through => :categorizations

  def self.min_cost(category)
    Order.minimum('cost', :conditions => ["categories.id = ?", category.id],
      :joins => "JOIN categorizations AS cat ON orders.id = cat.order_id
                 JOIN categories ON cat.category_id = categories.id")
  end
  def self.max_cost(category)
    Order.maximum('cost', :conditions => ["categories.id = ?", category.id],
      :joins => "JOIN categorizations AS cat ON orders.id = cat.order_id
                 JOIN categories ON cat.category_id = categories.id")
  end
end
