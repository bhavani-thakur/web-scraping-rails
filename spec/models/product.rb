require 'rails_helper'

RSpec.describe Product, type: :model do
  context 'Associations' do
    it 'belongs to a category' do
      should belong_to(:category)
    end
  end
end