class Order < ActiveRecord::Base
  include Workflow
  include WithAttachment
  include Sortable
  extend ModelsHelper
  acts_as_commentable

  workflow do
    state :DRAFT do
      event :publish, :transitions_to => :ACTIVE do |user|
        halt unless publishable_by?(user)
      end
      event :block, :transitions_to => :BLOCKED
      event :delete, :transitions_to => :DELETED
    end

    state :ACTIVE do
      event :finish, :transitions_to => :DONE
      event :block, :transitions_to => :BLOCKED
      event :delete, :transitions_to => :DELETED
    end

    state :DONE do
      event :block, :transitions_to => :BLOCKED
      event :delete, :transitions_to => :DELETED
    end
    state :BLOCKED
    state :DELETED
  end

  module PRIVACY
    OPEN,GENERAL,TOPLIST,PRIVATE,RESTRICTED = :OPEN,:GENERAL,:TOPLIST,:PRIVATE,:RESTRICTED
  end
  
  FONT = 1
  COLOR = 2
  DescLimit = 5000
  NameMinLimit = 25
  NameLimit = 100
  CostMinLimit = 1
  CostLimit = 10000
  CostPrivacy = 1
  CostUrgency = 1
  Max_Attachments = 3
  Max_Attachment_Size = 2.megabyte
  Commission = 0.1
  
  belongs_to  :user
  has_many    :categorizations, :dependent => :delete_all
  has_many    :categories,      :through => :categorizations
  has_many    :solutions,       :dependent => :delete_all
  has_many    :contributorships
  has_and_belongs_to_many :watchers, :class_name => "User", :join_table => "watchlist", :association_foreign_key => "watcher"
  attr_accessible :category, :name, :description, :term, :cost, :privacy, :font, :color, :eula
  
  validates_presence_of   :name,          :message => "Please, set descriptive name for the order"
  validates_length_of     :name,          :in => NameMinLimit..NameLimit, :message => "The number of characters should be in range #{NameMinLimit} - #{NameLimit}"
  validates_presence_of   :description,   :message => "Please, provide extended description for the order"
  validates_uniqueness_of :description,   :message => "The Order with the same description already exists"
  validates_length_of     :description,   :maximum => DescLimit, :message => "Maximum number of characters should be #{DescLimit}"
  validates_presence_of   :cost,          :message => "Please, define minimal fee for this order"
  validates_presence_of   :term,          :message => "Please, provide end date of the order"
#TODO  validates_inclusion_of  :term,          :in
  validates_inclusion_of  :cost,          :in => CostMinLimit..CostLimit, :message => "Please, provide value for the charge from $#{CostMinLimit}..$#{CostLimit} range"
  validates_acceptance_of :eula,          :on => :create, :message => "U should accept Terms of Use"
  after_update {|record| record.cost_changing}

  def cost_changing
    sum = rest unless rest.zero?
    if sum
      unless user.finance #New user don't have paypal account confirmed by system
        errors.add(:cost, "Please, set up your Paypal account")
        else
        if sum > self.user.finance.quantity  
          errors.add(:cost, 'U have not enough funds to provide such cost')
        elsif self.edit_restricted?
          if sum < 0
            errors.add(:cost, "U can't descrease cost of the order with solution")
          end
        end
        self.user.finance.update_attribute(:quantity, self.user.finance.quantity - sum)
        #TODO Get Admin by user_id = 1?   What behaviour when simultaneous update_attribute?
        admin = User.find_by_login("admin")
        admin.finance.update_attribute :quantity, admin.finance.quantity + sum
      end
    end
  end

  def rest
    total = 0
    if self.workflow_state_changed? and self.workflow_state_was == STATUS::DRAFT and self.active?
      total = self.cost
      total += FONT if self.font
      total += COLOR if self.color
    elsif self.active?
      if self.cost_was  #cost is treated as changed when creating new order
        total = self.cost - self.cost_was
      end
      if self.font_was != self.font
        total = self.font ? +FONT : -FONT
      end
      if self.color_was != self.color
        total = self.color ? +COLOR : - COLOR 
      end
    end
    total
  end
  
  def self.per_page
    property(:orders_per_page_count)
  end

  def self.search(viewer, status, sort, *args)
    sort ||= default_sort('main')
    sort[:column] ||=default_sort('main')[:column]
    sort[:order] ||=default_sort('main')[:order]

    if viewer.has_role?(nil)
      status = status ? [Order::STATUS::DONE] : [Order::STATUS::ACTIVE]
      privacy = Role::Visitor.privacy
    elsif viewer.has_role?(Role::User.name)
      owner = viewer.id
      status = status ? status : [Order::STATUS::ACTIVE]
      privacy = Role::User.privacy
      privacy_owner = Role::User.privacy_owner
    elsif viewer.admin?
      status = Role::Admin.status
      privacy = Role::Admin.privacy
    end

    Order.find(:all, :select => "orders.*",
      :joins => "LEFT OUTER JOIN contributorships ON contributorships.contribution_id = orders.id
                 JOIN users ON orders.user_id = users.id
                 JOIN categorizations AS cat ON orders.id = cat.order_id
                 JOIN categories ON cat.category_id = categories.id",
      :conditions => 
      Where {|w| #search
#        w.and "year(created_at) LIKE ?",  params[:year]     if params[:year]
#        w.and "month(created_at) LIKE ?", params[:month]    if params[:month]
#        w.and "day(created_at) LIKE ?",   params[:day]      if params[:day]
        w.and{|w1|
          w1.or "orders.name LIKE ?",              "%#{args[0]}%"
          w1.or "orders.description LIKE ?",       "%#{args[0]}%"
        } unless args[0].blank?
        w.and "workflow_state IN (?)",          status          #show orders only in specified status
        w.and{|w1| #all
          w1.and "privacy IN (?)",      privacy         #narrow search to visibility for viewer
          w1.or  {|sw|                                  #Owner can see all PRIVACY of his orders
            sw.and "orders.user_id =?", owner           
            sw.and "privacy IN (?)",    privacy_owner   
          }                             if privacy_owner
          w1.or {|cw| #contributor
            cw.and "contributorships.contributor_id = ?", viewer.id
          }
        }
      },
        :order => sort[:column] + " " + sort[:order],
        :group => 'id').paginate(:per_page => self.per_page, :page => sort[:page])
  end

  def self.solved_by(user, sort)
    sort ||= default_sort('main')
    sort[:column] ||=default_sort('main')[:column]
    sort[:order] ||=default_sort('main')[:order]
    Order.find(:all, :select => "orders.*",
      :joins => "INNER JOIN solutions ON solutions.order_id = orders.id
                JOIN users ON orders.user_id = users.id
                JOIN `categorizations` AS cat ON orders.id = cat.order_id
                JOIN categories ON cat.category_id = categories.id",
      :conditions => ["solutions.user_id = ?", user.id],
      :order => sort[:column] + " " + sort[:order]).paginate(:per_page => self.per_page, :page => sort[:page])
  end
  h= [
    ['Name', 'name'],
    ['Owner', 'users.login'],
    ['Category','categories.name'],
    ['Privacy', 'privacy'],
    ['End term', 'term', 'ASC', true],
    ['Solutions', 'solutions_count', 'DESC'],
    ['Cost', 'cost', 'DESC'],
    ['Status', 'workflow_state']
  ]
  headings_set('main', (h.pop;h))
  headings_set('drafts', [h[0], h[2], h[3], h[6], ['Update', 'updated_at']])
  headings_set('orders', h)
  headings_set('watchlist', h)
  headings_set('solved', h)

  #if order will have multiple categories
  def category
    categories[0].id
  end
  def category=(id)
    categories[0] = Category.find(id)
  end
  def end_time
    created_at + term.days
  end
  def urgent?
    term == 3
  end
  def expired?
    end_time.past?
  end
  def private?
    privacy != Order::PRIVACY::OPEN
  end
  def total_cost
    cost * (1 + Commission) + (font ? FONT : 0) + (color ? COLOR : 0) + (urgent? ? CostUrgency : 0) + (private? ? CostPrivacy : 0)
  end
  def commission
    cost * Commission if cost
  end
  def font_display
    "Bold font" if font
  end
  def color_display
    "Colorizing" if color
  end
  def advertisement
    font or color
  end
  def commentable_by?(user)
    (active? and !expired?) or (self.user == user)
  end
  def solvable_by?(user)
    active? and !user.author?(self) and !user.id.nil? and !expired?
  end
  def editable_by?(user)
    user.author?(self) and (draft? or active?)
  end
  def edit_restricted?
    active?
  end
  def publishable_by?(user)
    user.author?(self) and draft?
  end
  def cancelable_by?(user)
    user.author?(self) and self.solutions.empty?
  end
  def contributable_by?(user)
    user.author?(self) and active? and (privacy == PRIVACY::RESTRICTED or privacy == PRIVACY::PRIVATE or privacy == PRIVACY::TOPLIST)
  end
  def contributors    #already choosen contributors for instance order
    Contributorship.find(:all, :conditions => ["contribution_id = ?", self.id]).map(&:contributor)
  end
end
