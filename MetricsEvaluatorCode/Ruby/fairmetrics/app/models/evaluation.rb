class Evaluation < ApplicationRecord
  attr_accessor :metrics
  attr_accessor :subject
  
  validates_presence_of :collection, :resource, :executor, :title
  self.per_page = 10
end
