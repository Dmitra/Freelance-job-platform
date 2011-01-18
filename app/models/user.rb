require 'digest/sha1'
class User < ActiveRecord::Base
  include WithAttachment
  
  Max_Attachments = 3
  Max_Attachment_Size = 2.megabyte

  # Virtual attribute for the unencrypted password for its conditional validation in password_required?
  attr_accessor :password

  validates_presence_of     :login, :email
  with_options :if => :password_required? do |user|
    user.validates_presence_of     :password            
    user.validates_presence_of     :password_confirmation
    user.validates_length_of       :password,      :within => 4..40
    user.validates_confirmation_of :password
  end
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_format_of       :email,         :with => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i
  validates_length_of       :login,         :within => 3..40, :if => Proc.new{|user| user.errors.on("login").nil?}
  validates_length_of       :email,         :within => 6..40, :if => Proc.new{|user| user.errors.on("email").nil?}
  today = Date.today
  validates_inclusion_of    :birth_date,    :in => (today-36500)..today, :allow_nil => true
  validates_format_of       :homepage,      :with => /(((^http\:\/\/)|(^www\.)|^)((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i
  
  has_many :permissions
  has_many :roles,      :through => :permissions
  has_many :orders,     :dependent => :destroy
  has_many :solutions,  :dependent => :destroy
  has_many :contributorships
  has_one  :finance,    :dependent => :destroy
  has_many :sent_messages, :class_name => "Message", :foreign_key => "author_id"
  has_many :received_messages, :class_name => "MessageCopy", :foreign_key => "recipient_id"
  has_many :folders
  has_and_belongs_to_many :watchlist, :class_name => "Order", :join_table => "watchlist", :foreign_key => "watcher"
  
  before_save   :encrypt_password
  before_create :make_activation_code
  before_create :build_inbox

  # prevents a user from submitting a crafted form that bypasses activation
#  attr_protected :crypted_password, :salt, :remember_token, :remember_token_expires_at, :activation_code, :activated_at, :password_reset_code, :enabled
  attr_accessible :password, :password_confirmation, :email, :surname, :birth_date, :gender, :city, :country, :about, :avatar, :homepage, :portfolio, :spam
  
  class ActivationCodeNotFound < StandardError; end
  class AlreadyActivated < StandardError
    attr_reader :user, :message;
    def initialize(user, message=nil)
      @message, @user = message, user
    end
  end
  def self.search(search, page)
    paginate :per_page => property(:users_per_page_count), :page => page,
             :conditions => (['login like ?', "%#{search}%"])#,             :user => 'login'
  end
  # Finds the user with the corresponding activation code, activates their account and returns the user.
  #
  # Raises:
  #  +User::ActivationCodeNotFound+ if there is no user with the corresponding activation code
  #  +User::AlreadyActivated+ if the user with the corresponding activation code has already activated their account
  def self.find_and_activate!(activation_code)
    raise ArgumentError if activation_code.nil?
    user = find_by_activation_code(activation_code)
    raise ActivationCodeNotFound if !user
    raise AlreadyActivated.new(user) if user.active?
    user.send(:activate!)
    user
  end
  
  def active?
    # the presence of an activation date means they have activated
    !activated_at.nil?
  end

  # Returns true if the user has just been activated.
  def pending?
    @activated
  end
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    if login =~ /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/
      u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', login]
    else
      u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    end
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end
  
  def reset_password
    # First update the password_reset_code before setting the
    # reset_password flag to avoid duplicate email notifications.
    update_attribute(:password_reset_code, nil)
    @reset_password = true
  end  
  
  #used in user_observer
  def recently_forgot_password?
    @forgotten_password
  end
  
  def recently_reset_password?
    @reset_password
  end
   
  def self.find_for_forget(email)
    find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email]
  end
   
  def has_role?(rolename)
    if self.id == rolename
      return true
    else
      self.roles.find(:first, :conditions => [ "name = ?", rolename]) ? true : false
    end
  end
  
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  def author?(item)
    self == item.user
  end

  def inbox
    folders.find_by_name("Inbox")
  end
  
  def build_inbox
    folders.build(:name => "Inbox")
  end
  def years_old
    Date.today.year - birth_date.year
  end
  def contributors
    Contributorship.find(:all, :conditions => Where {|w|
        w.and "user_id = ?", self.id
    }, :order => "contributor_id DESC").map(&:contributor).uniq
  end
  def contributions
    Contributorship.find(:all, :conditions => ["contributor_id = ?", self.id]).map(&:contribution).compact
  end
  def is_contributor?(user)
    Contributorship.find(:all, :conditions => Where {|w|
        w.and "user_id = ?", self.id
        w.and "contributor_id = ?", user.id
    })
  end
  def admin?
    self.has_role?(Role::Admin.name)
  end
 
  protected
  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
      
  def password_required?
    crypted_password.blank? || !password.blank?
  end
  def make_password_reset_code
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
    
  def activate!
    @activated = true
    self.update_attribute(:activated_at, Time.now.utc)
    Permission.create(:role => Role.find_by_name(Role::NAME::USER), :user => self)
  end
end
