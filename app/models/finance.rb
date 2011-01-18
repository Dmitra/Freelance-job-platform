class Finance < ActiveRecord::Base
  validates_presence_of(:paypal, :if => :publish, :message => "Please, provide paypal account name")
  validates_uniqueness_of(:paypal, :on => :create, :message => "This paypal account is already registered")
  
  belongs_to :user
  
  def publish
    false #TODO checking paypal account on order publish
  end

end