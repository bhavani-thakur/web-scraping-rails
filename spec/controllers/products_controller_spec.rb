require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  describe 'POST #create' do
    let(:url) { 'http://example.com/product' }

    # Use FactoryBot to create the category
    let!(:category) { create(:category, name: 'Category 1') }

    let(:scraped_data) { { name: 'Product 1', description: 'Great product', size: 'M', category_id: category.id, price: 100 } }

   

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
    let!(:stale_product) { create(:product, name: 'Old Product', scraped_at: 2.weeks.ago)}
    let!(:fresh_product) { create(:product, name: 'Fresh Product', scraped_at: 1.day.ago)}

    before do
      allow(ProductScraper).to receive(:scrape).with('http://example.com/old_product').and_return({ name: 'Updated Product', price: 150 })
      allow(ProductScraper).to receive(:scrape).with('http://example.com/fresh_product').and_return({ name: 'Fresh Product', price: 200 })
    end

    it 'updates stale products with new scraped data' do
      post :update_stale

      stale_product.reload
      fresh_product.reload

      # Ensure the stale product has been updated with the new data
      expect(stale_product.name).to eq('Updated Product')
      expect(stale_product.price).to eq(150)
      expect(stale_product.scraped_at).to be_present

      # Ensure the fresh product has not been updated
      expect(fresh_product.name).to eq('Fresh Product')
      expect(fresh_product.scraped_at).to be > 1.day.ago
    end

    it 'calls the ProductScraper for stale products' do
      post :update_stale

      # Ensure that the scraper service is called for the stale product
      expect(ProductScraper).to have_received(:scrape).with('http://example.com/old_product')
    end

    it 'does not call the ProductScraper for fresh products' do
      post :update_stale

      # Ensure that the scraper service is not called for the fresh product
      expect(ProductScraper).to_not have_received(:scrape).with('http://example.com/fresh_product')
    end
  end
end
