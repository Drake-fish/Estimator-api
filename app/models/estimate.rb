class Estimate < ApplicationRecord
  belongs_to :project

  validates_presence_of :name, :optimistic, :realistic, :pessimistic, :note
end
