class PeoplePlaces < ActiveRecord::Base
  belongs_to :person
  belongs_to :place
end
