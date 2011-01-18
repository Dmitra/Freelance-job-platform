class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|                #Set to true to drop the table before creating it. Defaults to false.
      t.string		:login,                     :null => false
      t.string    :email
      t.string 		:crypted_password,          :limit => 40
      t.string 		:salt,                      :limit => 40    #random bits that are used as one of the inputs to a key derivation function
      t.timestamps
      t.string 		:remember_token
      t.datetime  :remember_token_expires_at
      t.string 		:activation_code,           :limit => 40
      t.datetime	:activated_at      
      t.string 		:password_reset_code,       :limit => 40
      t.boolean 	:enabled,                   :default => true     
      t.string 		:surname,                   :limit => 40
      t.date    	:birth_date
      t.boolean 	:gender                   #true is male
      t.string 		:city,                      :limit => 40
      t.string 		:country,                   :limit => 40
      t.text   		:about,                     :limit => 5000
      t.binary 		:avatar                    #set limit to 100x100px
      t.string 		:homepage,                  :limit => 1000#validate is a link?
      t.binary 		:portfolio                 #allow only .pdf?
      t.boolean 	:spam                     #true - send news, updates
      
    end
      add_index   :users,                     :login  #User is shown anywhere in the site via its login
  end

  def self.down
    drop_table :users
  end
end
