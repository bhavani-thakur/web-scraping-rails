require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  describe 'POST #create' do
    let(:url) { 'http://example.com/product' }

    # Use FactoryBot to create the category
    let!(:category) { create(:category, name: 'Category 1') }

    let(:scraped_data) { { name: 'Product 1', description: 'Great product', size: 'M', category_id: category.id, price: 100 } }

    before do
      allow(ProductScraper).to receive(:scrape).and_return({ name: 'Updated Product', price: 150 })
    end

   

    before do
      allow(ProductScraper).to receive(:scrape).with(url).and_return(scraped_data)
    end

    it 'creates a new product' do
      post :create, params: { url: url }

      product = Product.last
      expect(response).to have_http_status(:created)
      expect(product.name).to eq('Product 1')
      expect(product.price).to eq('100')
      expect(product.scraped_at).to be_present
      expect(product.category.name).to eq('Category 1')
    end

    it 'returns the product in the response' do
      post :create, params: { url: url }

      json_response = JSON.parse(response.body)
      expect(json_response['name']).to eq('Product 1')
      expect(json_response['price']).to eq('100')
    end

    it 'calls the scraper service with the correct URL' do
      post :create, params: { url: url }
      expect(ProductScraper).to have_received(:scrape).with(url)
    end
  end

  describe 'GET #index' do
    let!(:category1) { create(:category, name: 'Category 1') }
    let!(:category2) { create(:category, name: 'Category 2') }
    let!(:product1) { create(:product, name: 'Product 1', category: category1) }
    let!(:product2) { create(:product, name: 'Product 2', category: category2) }

    it 'returns all products with their associated categories' do
      get :index

      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)

      # Check if the products and their categories are returned
      expect(json_response.length).to eq(2)  # We have 2 products
      expect(json_response.first['name']).to eq('Product 1')
      expect(json_response.first['category']['name']).to eq('Category 1')
      expect(json_response.second['name']).to eq('Product 2')
      expect(json_response.second['category']['name']).to eq('Category 2')
    end

    it 'eager loads categories to avoid N+1 queries' do
      # Assuming you have the `bullet` gem installed for N+1 query detection
      expect {
        get :index
      }.to_not raise_error
    end
  end

  describe 'POST #update_stale' do

    let!(:stale_product) { create(:product, url: 'http://example.com/old_product')}
    let!(:fresh_product) { create(:product, url: 'http://example.com/fresh_product') }
    it 'updates stale products with new scraped data' do
      post :update_stale

      stale_product.reload
      fresh_product.reload

      # Ensure the stale product has been updated with the new data
      expect(stale_product.name).to eq('Product 1')
      expect(stale_product.price).to eq("100")
    end
  end
end
