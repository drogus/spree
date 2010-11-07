require File.dirname(__FILE__) + "/../spec_helper"
require "steak"
require 'capybara/rails'

RSpec.configuration.include Capybara, :type => :acceptance
RSpec.configuration.include Rails.application.routes.url_helpers

# Put your acceptance spec helpers inside /spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
