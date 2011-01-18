class Role < ActiveRecord::Base
  class Admin < Role
    def self.status
      Order::STATUS.constants
    end
    def self.privacy
      Order::PRIVACY.constants
    end
  end
  class User
    def self.status
      [Order::STATUS::ACTIVE, Order::STATUS::DONE]
    end
    def self.privacy_owner
      Order::PRIVACY.constants
    end
    def self.privacy
      [Order::PRIVACY::OPEN, Order::PRIVACY::GENERAL]
    end
  end
  class Visitor
    def self.status
      [Order::STATUS::ACTIVE, Order::STATUS::DONE]
    end
    def self.privacy
      [Order::PRIVACY::OPEN]
    end
  end
  
  has_many :permissions
  has_many :users, :through => :permissions  
end
