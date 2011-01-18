class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name,   :null => false
    end
      [Role::Admin, Role::User, Role::Visitor].each{|role| Role.create(:name => role.name)}
  end

  def self.down
    drop_table :roles
  end
end

#class CreateRoles < ActiveRecord::Migration
#  def self.up
#    create_table :roles, :id => false  do |t|
#      t.string :name,   :null => false
#      t.string :order_privacy, :null => false
#      t.string :order_status, :null => false
#    end
#    add_index :roles, [:name, :order_privacy, :order_status], :unique => true
#    [Role::Admin, Role::User, Role::Visitor].each{|role|
#        role.privacy.each{|privacy|
#          role.status.each{|status|
#            Role.create(:name => role.name, :order_privacy => privacy, :order_status => status)
#          }
#        }
#     }
#  end