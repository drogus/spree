source 'http://rubygems.org'

gem "spree", :path => File.dirname(__FILE__)

# gem 'mysql'
gem 'sqlite3-ruby'
gem 'ruby-debug' if RUBY_VERSION.to_f < 1.9
gem "rdoc",  "2.2"
gem 'devise', :git => 'git://github.com/plataformatec/devise.git'

gemspec

group :test do
  gem 'rspec-rails', '~> 2.1.0'
  gem 'factory_girl_rails'
  gem 'steak', '>= 1.0.0.rc.2'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'fabrication'
  gem 'launchy'
end
