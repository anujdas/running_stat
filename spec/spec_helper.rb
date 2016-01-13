$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'rspec'
require 'running_stat'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  # global configuration goes here
end
