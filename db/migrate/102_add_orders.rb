class AddOrders < ActiveRecord::Migration
#            user_id  name                description                           privacy                         status              term   ads
  @@orders = [[2,"First sample order *******",  "I want the best logo",                  nil, Order::STATUS::ACTIVE],
              [3,"Expired Customers ********",  "Give my company a brand new Name",      Order::PRIVACY::GENERAL, Order::STATUS::ACTIVE, -1],
              [3,"Yet another order ********",  "Give my firm a slogan",                 Order::PRIVACY::GENERAL, Order::STATUS::DONE],
              [2,"Order1 of the User *******",  "descriptive description1"],
              [2,"Order2 of the User *******",  "descriptive description2"],
              [2,"Order3 of the User *******",  "descriptive description3"],
              [2,"Order4 of the User *******",  "descriptive description4"],
              [2,"Order5 of the User *******",  "descriptive description5"],
              [2,"Order6 of the User *******",  "descriptive description6"],
              
#             DO NOT CHANGE ANY EXISTING RECORDS - THEY ARE BUNDLED WITH OTHER TABLES BY ID

              [2,"Spam should be blocked ***", "The logotype is for animation studio",  nil, Order::STATUS::BLOCKED],
              [2,"Trash should be deleted **", "The logotype is for animation studio1", nil, Order::STATUS::DELETED],
              [2,"This order should be done*", "The logotype is for animation studio2", nil, Order::STATUS::DONE],
              [2,"Restricted data **********", "The logotype is for animation studio3", Order::PRIVACY::RESTRICTED, Order::STATUS::ACTIVE],
              [2,"Private data *************", "The logotype is for animation studio4", Order::PRIVACY::PRIVATE, Order::STATUS::ACTIVE],
              [2,"Toplist data *************", "The logotype is for animation studio5", Order::PRIVACY::TOPLIST, Order::STATUS::ACTIVE],
              [3,"Yet another active1 ******", "Give my firm a slogan1",                nil, Order::STATUS::ACTIVE, 1, ["font"]],
              [3,"Yet another active2 ******", "Give my firm a slogan2",                nil, Order::STATUS::ACTIVE, 2, ["font", "color"]],
              [3,"Yet another active3 ******", "Give my firm a slogan3",                nil, Order::STATUS::ACTIVE],
              [3,"Yet another active4 ******", "Give my firm a slogan4",                nil, Order::STATUS::ACTIVE],
              [3,"Yet another active5 ******", "Give my firm a slogan5",                Order::PRIVACY::PRIVATE, Order::STATUS::ACTIVE]
  ]
  def self.up
    @@orders.each_with_index{|data, i| order = Order.new(
          :name         => data[1],
          :description  => data[2]
      )
      order.user_id   = data[0]
      order.cost        = 5+i
      order.term        = data[5] ? data[5] : (rand(2) == 0 ? 3 : 7)
      order.privacy     = data[3] unless data[3].nil?
      order.workflow_state = data[4] unless data[4].nil?
      order.font        = 1 if data[6] and data[6].include?("font")
      order.color       = 1 if data[6] and data[6].include?("color")
      order.save(false)
      Categorization.create!(:category => Category.find(rand(Category.count)+1), :order => order)
    }
  end

  def self.down
  end
end
