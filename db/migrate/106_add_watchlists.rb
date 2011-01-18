class AddWatchlists < ActiveRecord::Migration
#             watcher  order_id
  @@watchlist = [[2, 2],
                 [2, 3],
                 [2, 16],
                 [2, 17],
                 [2, 18],
                 [2, 19],
                 [2, 20],
                 [3, 1],
                 [4, 1],
                 [4, 2],
                 [4, 3],
                 [4, 12]
  ]
  def self.up
    @@watchlist.each{|data| 
          User.find(data[0]).watchlist << Order.find(data[1])
    }
  end

  def self.down
  end
end
