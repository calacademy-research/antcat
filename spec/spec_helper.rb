# coding: UTF-8
require 'devise'
require 'spork'


Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require_relative '../config/environment'
  require 'rspec/rails'

  require 'webmock/rspec'
  WebMock.disable_net_connect! allow_localhost: true

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.mock_with :rspec
    config.use_transactional_fixtures = true
    config.fail_fast = false

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:all) do
      DeferredGarbageCollection.start
    end

    config.after(:all) do
      DeferredGarbageCollection.reconsider
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
    config.infer_spec_type_from_file_location!
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

def with_versioning
  was_enabled = PaperTrail.enabled?
  PaperTrail.enabled = true
  begin
    yield
  ensure
    PaperTrail.enabled = was_enabled
  end
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
end



def setup_version taxon_id, whodunnit=nil
  version = FactoryGirl.create :version, item_id: taxon_id, event: 'create', item_type: 'Taxon', whodunnit: whodunnit.nil? ? nil : whodunnit.id
  change = FactoryGirl.create :change, user_changed_taxon_id: taxon_id
  FactoryGirl.create :transaction, paper_trail_version_id: version.id, change_id: change.id
  change
end
