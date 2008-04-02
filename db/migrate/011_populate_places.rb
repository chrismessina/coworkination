# Populates the places table with .csv data
class PopulatePlaces < ActiveRecord::Migration
  def self.up
    FasterCSV.foreach("#{RAILS_ROOT}/lib/dev/csv_flatfiles/COWORKINATION_Places_02.csv") do |row|
      Place.create( :org => row[0], 
                    :street_address => row[1], 
                    :locality => row[2],
                    :region => row[3],
                    :postal_code => row[4],
                    :country_name => row[5],
                    :tel => row[6],
                    :email => row[7],
                    :url => row[8],
                    :photo => row[9])
    end
  end

  def self.down
    Place.delete_all
  end
end
