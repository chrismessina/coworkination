class AlterUsersAddRestfulAuthenticationCols < ActiveRecord::Migration
  def self.up
    add_column :people,  :crypted_password,           :string, :limit => 40
    add_column :people,  :salt,                       :string, :limit => 40
    add_column :people,  :remember_token,             :string
    add_column :people,  :remember_token_expires_at,  :datetime
    add_column :people,  :activation_code,            :string, :limit => 40
    add_column :people,  :activated_at,             :datetime
    add_column :people,  :identity_url,             :string    
  end

  def self.down
    remove_column :people,  :crypted_password
    remove_column :people,  :salt
    remove_column :people,  :remember_token
    remove_column :people,  :remember_token_expires_at
    remove_column :people,  :activation_code
    remove_column :people,  :activated_at
    remove_column :people,  :identity_url
  end
end
