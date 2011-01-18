class AddComments < ActiveRecord::Migration
#      commentable  order_id  user_id      body               description              
  @@comments = [['Brief',     1, 2, "", "this order is very complicated"],
                ['Brief',     1, 2, "", "this order is very complicated"],
                ['Brief',     1, 2, "", "this order is very complicated"],
                ['Order',     1, 1, "First comment title", "this order is very complicated"],
                ['Order',     1, 2, "Another comment title", "this order is very complicated"],
                ['Order',     1, 3, "Another comment title", "this order is very complicated"],
                ['Order',     1, 4, "Another comment title", "this order is very complicated"],
                ['Order',     1, 5, "Another comment title", "this order is very complicated"],
                ['Order',     1, 5, "Another comment title", "this order is very complicated"],
                ['Solution',  4, 1, "Soluttion comment title", "Yet Another comment"],
                ['Solution',  4, 2, "Another comment title", "Yet Another comment"],
                ['Solution',  4, 3, "Another comment title", "Yet Another comment"],
                ['Solution',  4, 4, "Another comment title", "Yet Another comment"],
                ['Solution',  4, 5, "Another comment title", "Yet Another comment"],
                ['Solution',  4, 5, "Another comment title", "Yet Another comment"]
  ]
  def self.up
    @@comments.each{|data| Comment.create(
                            :commentable_type => data[0],
                            :commentable_id => data[1],
                            :user_id => data[2],
                            :title   => data[3],
                            :comment => data[4]
                            )
    }
  end

  def self.down
  end
end
