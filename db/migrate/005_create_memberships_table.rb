class CreateMembershipsTable < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.column :person_id, :integer
      t.column :place_id, :integer
      t.column :role, :string
      t.column :home, :boolean
      t.column :created_at, :datetime       # created at (auto)
      t.column :updated_at, :datetime       # upated at (auto)
    end  
  end

  def self.down
    drop_table :memberships
  end
end
