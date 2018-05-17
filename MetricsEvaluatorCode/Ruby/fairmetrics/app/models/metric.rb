class Metric < ApplicationRecord
  has_and_belongs_to_many :collections
end
