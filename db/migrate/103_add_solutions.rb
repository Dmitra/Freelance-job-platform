class AddSolutions < ActiveRecord::Migration
#           order_id  user_id   body    description       
  @@solutions = [[1,1,"Logo", "the best logo U ever seen"],
                 [1,4,"Logo1", "this logo is even better then previous"],
                 [1,1,"Logo2", "this logo is even better then previous", Solution::STATUS::EVALUATED, 2],
                 [1,4,"Logo3", "this logo is even better then previous", Solution::STATUS::EVALUATED, 3],
                 [1,4,"Logo4", "this logo is even better then previous", Solution::STATUS::DELETED],
                 [1,4,"Logo5", "this logo is even better then previous"],
                 [2,2,"Brand Name", "The name is: \"WhoIS\""],
                 [2,4,"Brand Name1", "Yet Another Naming"],
                 [16,2, "Slogan 1", "slogan for order"],
                 [17,2, "Slogan 2", "slogan for order"],
                 [18,2, "Slogan 3", "slogan for order"],
                 [19,2, "Slogan 4", "slogan for order"],
                 [20,2, "Slogan 5", "slogan for order"]
  ]
  def self.up
    @@solutions.each{|data| solution = Solution.new(
          :body         => data[2],
          :description  => data[3],
          :attachments  => data[5]
    )
    solution.order_id   = data[0]
    solution.user_id    = data[1]
    solution.workflow_state = data[4]     if data[4]
    solution.rating = data[5]     if data[5]
    solution.save(false)}
  end

  def self.down
  end
end
