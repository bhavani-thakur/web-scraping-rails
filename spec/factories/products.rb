FactoryBot.define do
  factory :product do
    name { 'Product 1' }   # Ensure this matches the attribute name in your Product model
    price { 100 }           # Assuming price is an integer (if it's a decimal, use `100.0`)
    size { 'Free size' }
    association :category   # Automatically create a category associated with this product
  end
end

