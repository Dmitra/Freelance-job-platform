class Asset < ActiveRecord::Base
  has_attached_file :data
  belongs_to :attachable, :polymorphic => true
  validates_inclusion_of  :data_file_size,    :in => 0..2100000, :message => "exceeding file size limit"
  validates_each :data_file_name do |record, attr, value|
    record.errors.add_to_base 'Attachments quantity limit exceeded' if record.allowed_attachments == 0
  end
  
  def url(*args)
    data.url(*args)
  end
  
  def name
    data_file_name
  end
  
  def content_type
    data_content_type
  end
  
  def file_size
    data_file_size
  end
  def allowed_attachments
    attachable.class::Max_Attachments - attachable.assets.count    
  end
end