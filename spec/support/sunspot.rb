# coding: UTF-8
# See https://github.com/CompanyBook/sunspot_massive_record/wiki/Rspec-and-Sunspot-Rails

# Put this in spec/support/
# Will use a sunspot stub session as default in all tests,
# but if you include the EnableSunspot module inside of a describe block
# it will index record and make them searchable inside of that block.

Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)

module EnableSunspot
  extend ActiveSupport::Concern

  included do
    before(:all) do
      Sunspot.session = Sunspot.session.original_session
    end

    after do
      Sunspot.remove_all! 
    end

    after(:all) do
      Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    end
  end
end


#
# Make sunspot index right away in test environment.
#
module Sunspot
  module Rails
    module Searchable
      module InstanceMethods
        def solr_index
          solr_index!
        end
        
        def solr_remove_from_index
          solr_remove_from_index!
        end
      end
    end
  end
end
