require 'rails_helper'

RSpec.describe Project, type: :model do
 it { should have_many(:estimates).dependent(:destroy) }
 # Validation tests
 # ensure columns title and created_by are present before saving
 it { should validate_presence_of(:name) }
 it { should validate_presence_of(:description) }
end
