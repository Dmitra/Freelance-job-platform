class AddUsers < ActiveRecord::Migration
#             login           Role          password          paypal login    money   surname       birth_date        gender   city     country   about                 avatar                          homepage                portfolio                     spam
  @@users = [["admin",    "Role::Admin","admin", "paypal@intelliart.net",  0,     "Moderator", Date.new(2000,1,1), true,  "Tokyo",   "Japan",   "tell me that", File.new("test/data/admin.gif"), "http://cubicstudio.com.ua"],
             ["user",     "Role::User", "user",       "1@intelliart.net", 20,     "Tester",    Date.new(2000,1,2), false, "NY",      "USA",     "simple user",  File.new("test/data/user.jpeg"), "http://dmitra.com", File.new("test/data/user.pdf"),      true],
             ["customer", "Role::User", "customer",   "2@intelliart.net", 50,     "Consumer",  Date.new(2000,1,3), true,  "Kyiv",    "Ukraine", "no info",      File.new("test/data/customer.jpeg"), "http://google.com", File.new("test/data/customer.pdf"),  true],
             ["agent",    "Role::User", "agent",                    nil, nil,     "Man",       Date.new(2000,1,4), false, "Monreal", "Canada",  "how are U?",   File.new("test/data/agent.gif"), "http://intelliart.net", File.new("test/data/agent.pdf"),  false],
             ["agent1",    "Role::User", "agent"],
             ["agent2",    "Role::User", "agent"],
             ["agent3",    "Role::User", "agent"],
             ["agent4",    "Role::User", "agent"],
             ["agent5",    "Role::User", "agent"],
             ["agent6",    "Role::User", "agent"],
             ["agent7",    "Role::User", "agent"],
             ["agent8",    "Role::User", "agent"],
             ["agent9",    "Role::User", "agent"],
             ["agent10",   "Role::User", "agent"]
             ]
  def self.up
    @@users.each{|data|
      user = User.new(:email      => data[0]+"@intelliart.net",
                      :password   => data[2],
                      :password_confirmation => data[2],
                      :surname    => data[5],
                      :birth_date => data[6],
                      :gender     => data[7],
                      :city       => data[8],
                      :country    => data[9],
                      :about      => data[10],
                      :avatar     => data[11],
                      :homepage   => data[12],
                      :portfolio  => data[13],
                      :spam       => data[14])
      user.login = data[0]      #mass-assignment of login forbidden
      user.activated_at = Time.now
      user.save(false)
      Permission.create!(:role => Role.find_by_name(data[1]), :user => user) 
      user.create_finance(:paypal => data[3], :quantity => data[4])     unless data[3].nil?
    }
  end

  def self.down
#      @@users.each_with_index{|data, i|
#      User.find_by_login(data[0]).delete
#    }
  end
end
