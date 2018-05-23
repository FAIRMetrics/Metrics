class Collection < ApplicationRecord
   has_and_belongs_to_many :metrics
   
   validates_presence_of :name, :contact, :organization
end
