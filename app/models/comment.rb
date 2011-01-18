class Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true
  default_scope :order => 'created_at ASC'
  belongs_to :user
  validates_presence_of :comment, :message => "Please, provide comment content"
  validates_inclusion_of :commentable_type, :in => %w(Order Solution Brief)
  
  named_scope :filter, lambda {|filter| filter == 'all' ? {} : {:conditions => ["user_id IN (?)", filter]}}
  named_scope :brief, lambda {|order| {:conditions => {:commentable_id => order.id, :commentable_type => 'Brief'}}}
end
