require 'rails_helper'

RSpec.describe Category, type: :model do
  context 'Associations' do
    it 'has many products' do
      should have_many(:products)
    end
  end
end