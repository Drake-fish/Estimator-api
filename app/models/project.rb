class Project < ApplicationRecord
  has_many :estimates, dependent: :destroy

  validates_presence_of :name, :description

end
