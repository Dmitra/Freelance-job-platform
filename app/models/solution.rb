class Solution < ActiveRecord::Base
  include Workflow
  include WithAttachment
  include Sortable
  acts_as_commentable
  
  workflow do
    state :NEW do
      event :evaluate, :transitions_to => :EVALUATED do |user, rank|
        update_attribute(:rating, rank)
        halt unless acceptable_by?(user)
      end
      event :delete, :transitions_to => :DELETED do |user|
        halt unless deletable_by?(user)
      end
      event :refuse, :transitions_to => :REFUSED do |user|
        halt unless acceptable_by?(user)
      end
    end
    state :EVALUATED do
      event :evaluate, :transitions_to => :EVALUATED do |user, rank|
        update_attribute(:rating, rank)
        halt unless acceptable_by?(user)
      end
      event :accept, :transitions_to => :ACCEPTED do |user|
        order.finish!
        halt unless acceptable_by?(user)
      end
      event :refuse, :transitions_to => :REFUSED do |user|
        halt unless acceptable_by?(user)
      end
      event :delete, :transitions_to => :DELETED do |user|
        halt unless deletable_by?(user)
      end
    end
    state :ACCEPTED
    state :REFUSED do
      event :evaluate, :transitions_to => :EVALUATED do |user, rank|
        update_attribute(:rating, rank)
        halt unless acceptable_by?(user)
      end
    end
    state :DELETED do
      event :restore, :transitions_to => :NEW do |user|
        halt unless restorable_by?(user)
      end
    end
  end

  Max_Attachments = 3
  Max_Attachment_Size = 2.megabyte

  validates_presence_of     :body
  validates_uniqueness_of   :description, :scope => :order_id, :message => "The Solution with the same description already exists"
  validates_inclusion_of    :rating, :in => 1..3

  belongs_to :order,        :counter_cache => true
  belongs_to :user
  
  attr_accessible :body, :description, :attachment
  
  headings_set( 'solutions',
    [
      ['#', 'id'],
      ['Name', 'body'],
      ['Created date', 'created_at'],
      ['Comments', 'comments_count', 'DESC'],
      ['Rating', 'rating']
    ])

  def self.per_page
    property(:pagination_per_page_count)
  end
  def self.search(viewer, sort, *args)
    sort ||= default_sort('solutions')
    sort[:column] ||=default_sort('solutions')[:column]
    sort[:order] ||=default_sort('solutions')[:order]

    status = Solution.states - [Solution::STATUS::DELETED]
#TODO do not show solutions for restricted orders (for Solutions index per user)
    Solution.find(:all, :conditions => Where {|w|
           w.and "body LIKE ?",   args[0]   unless args[0].blank?
           w.and "workflow_state IN (?)", status   if status
           w.or "user_id = ?",   viewer.id
           }, :order => sort[:column] + " " + sort[:order]
             ).paginate(:per_page => self.per_page, :page => sort[:page])
  end
  def acceptable_by?(user)
    user.author?(self.order)
  end
  def deletable_by?(user)
    user.author?(self) and !deleted?
  end
  def restorable_by?(user)
    user.author?(self) and order.active?
  end
end
