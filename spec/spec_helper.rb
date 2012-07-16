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

def create_subfamily name_or_attributes = 'Dolichoderinae', attributes = {}
  create_taxon name_or_attributes, :subfamily, :subfamily_name, attributes
end

def create_tribe name_or_attributes = 'Attini', attributes = {}
  create_taxon name_or_attributes, :tribe, :tribe_name, attributes
end

def create_taxon name_or_attributes = 'Atta', attributes = {}
  create_taxon name_or_attributes, :genus, :genus_name, attributes
end

def create_genus name_or_attributes = 'Atta', attributes = {}
  create_taxon name_or_attributes, :genus, :genus_name, attributes
end

def create_subgenus name_or_attributes = 'Atta (Subatta)', attributes = {}
  create_taxon name_or_attributes, :subgenus, :subgenus_name, attributes
end

def create_species name_or_attributes = 'Atta major', attributes = {}
  create_taxon name_or_attributes, :species, :species_name, attributes
end

def create_subspecies name_or_attributes, attributes = {}
  create_taxon name_or_attributes, :subspecies, :subspecies_name, attributes
end

def create_taxon name_or_attributes, taxon_factory, name_factory, attributes
  if name_or_attributes.kind_of? String
    name, epithet = get_name_parts name_or_attributes
    attributes = attributes.reverse_merge name: FactoryGirl.create(name_factory, name: name, epithet: epithet)
  else
    attributes = name_or_attributes
  end

  build = attributes.delete :build
  FactoryGirl.send(build ? :build : :create, taxon_factory, attributes)
end

def get_name_parts name
  parts = name.split ' '
  epithet = parts.last unless parts.size < 2
  return name, epithet
end

def create_name name
  name, epithet = get_name_parts name
  FactoryGirl.create :name, name: name, epithet: epithet
end

def create_junior_synonym senior, attributes = {}
  junior = create_genus attributes.merge synonym_of: senior, status: 'synonym'
  synonym = Synonym.create! senior_synonym: senior, junior_synonym: junior
  junior
end
