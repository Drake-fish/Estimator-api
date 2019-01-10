class Project < ApplicationRecord
  has_many :estimates, dependent: :destroy

  validates_presence_of :name, :description

  def self.all_estimates params
    Project.find(params[:id]).estimates
  end
end
