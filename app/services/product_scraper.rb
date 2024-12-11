require 'selenium-webdriver'
require 'logger'

class ProductScraper
  # Configure logger
  LOGGER = Logger.new(STDOUT)

  def self.scrape(url)
    driver = setup_driver
    driver.navigate.to url

    # Wait until the necessary elements are loaded
    wait_for_page_to_load(driver)

    breadcrumbs = extract_breadcrumbs(driver)
    category = find_or_create_category(breadcrumbs)
    
    name = extract_name(driver)  # Assuming the name is always the third breadcrumb
    description = extract_description(driver)
    price = extract_price(driver)
    size = extract_size(driver)

    driver.quit

    {
      name: name,
      description: description,
      size: size,
      price: price,
      category_id: category.id,
      url: url
    }
  end

  private

  # Setup Selenium WebDriver with necessary options
  def self.setup_driver
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')

    Selenium::WebDriver.for :chrome, options: options
  end

  # Wait for essential elements to load
  def self.wait_for_page_to_load(driver)
    wait = Selenium::WebDriver::Wait.new(timeout: 10)
    wait.until { driver.find_elements(css: 'div.r2CdBx a.R0cyWM').any? }
    LOGGER.info("Page loaded successfully.")
  end

  # Extract breadcrumbs and return them as an array of hashes
  def self.extract_breadcrumbs(driver)
    breadcrumb_elements = driver.find_elements(css: 'div.r2CdBx a.R0cyWM')
    breadcrumb_elements.map do |breadcrumb|
      { text: breadcrumb.text.strip, href: breadcrumb['href'] }
    end
  end

  # Find or create a category from the breadcrumbs
  def self.find_or_create_category(breadcrumbs)
    category_name = breadcrumbs[1][:text]
    category = Category.find_or_create_by(name: category_name)
    LOGGER.info("Category '#{category_name}' found or created with ID #{category.id}.")
    category
  end

   # Extract product description, return nil if not found
  def self.extract_name(driver)
    name_element = driver.find_elements(css: 'div.KalC6f p').first
    name = name_element&.text&.strip
    name.nil? ? LOGGER.warn("name not found.") : name
  end

  # Extract product description, return nil if not found
  def self.extract_description(driver)
    description_element = driver.find_elements(css: 'h1._6EBuvT span.VU-ZEz').first
    description = description_element&.text&.strip
    description.nil? ? LOGGER.warn("Description not found.") : description
  end

  # Extract product price, return nil if not found
  def self.extract_price(driver)
    price_element = driver.find_elements(css: 'div.Nx9bqj.CxhGGd').first
    price = price_element&.text&.strip
    price.nil? ? LOGGER.warn("Price not found.") : price
  end

  # Extract size information
  def self.extract_size(driver)
    size_element = driver.find_elements(css: 'ul.hSEbzK li a.CDDksN').first
    size = size_element&.text&.strip
    size.nil? ? LOGGER.warn("Size not found.") : size
  end
end
