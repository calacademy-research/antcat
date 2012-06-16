# coding: UTF-8

require 'spork'
Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require_relative '../config/environment'
  require 'rspec/rails'

  require 'webmock/rspec'
  WebMock.disable_net_connect! :allow_localhost => true

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.mock_with :rspec
    config.use_transactional_fixtures = true
    config.fail_fast = false
  end
end

Spork.each_run do
  FactoryGirl.reload

  # When a reference is parsed, it returns the text of what was matched in :matched_text
  # The trouble is that none of the hundreds of existing tests account for this new field,
  # so they would all fail without either 1) fixing them all (and all future) to test the
  # :matched_text field, or 2) remove that field
  class Object
    def deep_delete_matched_text
      if respond_to? :keys
        delete :matched_text
        for key in keys
          self[key].deep_delete_matched_text
        end
      elsif respond_to? :each
        each.map {|e| e.deep_delete_matched_text}
      end
      self
    end
  end
  class Citrus::Match
    def value_with_matched_text_removed
      value.deep_delete_matched_text
    end
  end

end

puts "in #{`pwd`}"

def create_genus name
  FactoryGirl.create :genus, name: FactoryGirl.create(:genus_name, name: name)
end

def create_subspecies name, attributes = {}
  attributes = attributes.merge name: FactoryGirl.create(:subspecies_name, name: name)
  FactoryGirl.build :subspecies, attributes
end
