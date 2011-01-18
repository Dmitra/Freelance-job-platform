class CreateContributorships < ActiveRecord::Migration
  def self.up
    create_table :contributorships    do |t|
      t.references  :user, :contributor,   :null => false
      t.references  :contribution
      t.timestamps
    end
    execute "CREATE UNIQUE INDEX `index_c-ships_on_user_id_and_c-tor_id_and_c-ion_id` ON `contributorships` (`user_id`, `contributor_id`, `contribution_id`)"
  end

  def self.down
    drop_table :contributorships
  end
end
