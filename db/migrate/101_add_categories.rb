class AddCategories < ActiveRecord::Migration
#           order_id  user_id   body    description       
  @@categories = %w[Names Claims Writing Copywriting]
  def self.up
    @@categories.each{|data| 
       Category.new( :name => data, :recommended_cost => rand(20)).save(false)
    }
  end

  def self.down
  end
end
