module WithAttachment
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      has_many :assets, :as => :attachable, :dependent => :destroy
    end
    base.send(:include, InstanceMethods)
  end # self.included
  module ClassMethods
  end # ClassMethods

  module InstanceMethods
    def allowed_attachments
      self.class::Max_Attachments - self.assets.count
    end
  end
end