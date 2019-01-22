class Project < ApplicationRecord
  has_many :estimates, dependent: :destroy
  has_ancestry
  validates_presence_of :name, :description

  def self.get_all_projects_and_estimates
    Project.includes(:estimates).where(ancestry: nil).order(created_at: :desc)
  end

end
