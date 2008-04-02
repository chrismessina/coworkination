class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.column :login, :string              # login (username)
      t.column :given_name, :string         # given name (first name)  
      t.column :family_name, :string        # family name (last name)
      t.column :org, :string                # organization's name
      t.column :street_address, :string     # street address 
      t.column :locality, :string           # locality (city)
      t.column :region, :string             # region (state/province)
      t.column :postal_code, :string        # postal code (ZIP)
      t.column :country_name, :string       # country name
      t.column :tel, :string                # tel (telephone number)
      t.column :email, :string              # email
      t.column :url, :string                # url
      t.column :photo, :string              # photo url
      t.column :created_at, :datetime       # created at (auto)
      t.column :updated_at, :datetime       # upated at (auto)
    end
  end

  def self.down
    drop_table :people
  end
end
