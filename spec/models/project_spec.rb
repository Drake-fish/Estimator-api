require 'rails_helper'

RSpec.describe Project, type: :model do
 it { should have_many(:estimates).dependent(:destroy) }
 it { should validate_presence_of(:name) }
 it { should validate_presence_of(:description) }
end
