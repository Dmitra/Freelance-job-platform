class Contributorship < ActiveRecord::Base
  belongs_to :user
  belongs_to :contributor, :class_name => "User"
  belongs_to :contribution, :class_name => "Order"
end
