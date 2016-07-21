require 'protected_attributes'

PaperTrail::Rails::Engine.eager_load!

module PaperTrail
  class Version < ::ActiveRecord::Base
    attr_accessible :change_id
  end
end
