# Scraping

This project is a Rails-based web scraping application designed to scrape product data from external websites and manage the scraped data effectively using a PostgreSQL database.

## Features

- **Category and Product Management**: Manage categories and associated products.
- **RESTful API**: Provides RESTful controllers for efficient data management.
- **Database Integration**: Includes migrations for creating and managing the database structure.
- **JSON Data Rendering**: Easily render data in JSON format for integration.
- **Extensibility**: Easily integrable with existing Rails applications.

## Getting Started

### Prerequisites
- **Ruby**: Version 3.0.0 or later.
- **Rails**: Version 7.1.5.
- **PostgreSQL**: Ensure PostgreSQL is installed and running.

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/bhavani-thakur/web-scraping-rails.git
   cd web-scraping-rails
   ```
2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   rails db:create
   rails db:migrate
   ```

4. Start the server:
   ```bash
   rails server
   ```
   The application should now be accessible at `http://localhost:3000`.

## Configuration
- Update `config/database.yml` with your PostgreSQL credentials.

## Usage
- Submit URLs to scrape product data using the `SubmitURL` component.
- Search and filter products using the provided search functionality.

## Testing
- Run the test suite with:
  ```bash
  rspec
  ```

## Services
- **Scraping Service**: Uses `selenium-webdriver` for scraping.
- **Background Jobs**: Optional setup for scraping stale products asynchronously.

## Deployment Instructions
- Ensure all environment variables are set up for production.
- Use a production-ready web server like Puma.
- Migrate the database in the production environment:
  ```bash
  rails db:migrate
  ```

## Dependencies

### Gems
- `selenium-webdriver`: HTML parsing.
- `pg`: PostgreSQL integration.
- `rspec-rails`: Testing framework.
- `factory_bot_rails`: Test data generation.
- `faker`: Generate fake data for testing.

## License
This project is licensed under the MIT License.

---

# web-scraping-rails