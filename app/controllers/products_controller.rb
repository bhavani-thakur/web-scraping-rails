class ProductsController < ApplicationController
  def create
    url = params[:url]
    scraped_data = ProductScraper.scrape(url)
    product = Product.create(scraped_data.merge(scraped_at: Time.current))

    render json: product, status: :created
  end

  def index
    # Eager load categories to avoid N+1 queries
    products = Product.includes(:category)
    
    # If a query is provided, filter products by name
    if params[:query].present?
      products = products.where('name LIKE ?', "%#{params[:query]}%")
    end

    # Render filtered products with their associated category
    render json: products.as_json(include: :category), status: :ok
  end



  def update_stale
    Product.where('scraped_at < ?', 1.week.ago).find_each do |product|
      scraped_data = ProductScraper.scrape(product.url)
      product.update(scraped_data.merge(scraped_at: Time.current))
    end
    head :ok
  end
end
