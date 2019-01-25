require 'rails_helper'

RSpec.describe Estimate, type: :model do
  # Association test
  # ensure an item record belongs to a single todo record
  it { should belong_to(:project) }
  # Validation test
  # ensure column name is present before saving
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:optimistic) }
  it { should validate_presence_of(:realistic) }
  it { should validate_presence_of(:pessimistic) }
end
