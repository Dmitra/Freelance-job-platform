class AddContributors < ActiveRecord::Migration
#                 customer  user_id   order_id
  @@contributors = [[2, 4],
                    [2, 4, 14],
                    [2, 4, 15],
                    [2, 3, 14],
                    [3, 2, 20]
  ]
  def self.up
    @@contributors.each{|data| contributor = Contributorship.new(
          :user_id      => data[0],
          :contributor  => User.find(data[1]))
          contributor.contribution = Order.find(data[2])    if data[2]
          contributor.save(false)
    }
  end

  def self.down
  end
end
