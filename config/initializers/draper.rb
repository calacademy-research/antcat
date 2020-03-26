# frozen_string_literal: true

module Draper
  class HelperProxy
    # Makes it possible to call eg `helpers.reference_path(reference)` in decorators.
    include Rails.application.routes.url_helpers
  end
end

# Monkey patch for using class methods in Draper.
# Via https://github.com/drapergem/draper/issues/732
module Draper
  module Decoratable
    module ClassMethods
      def decorate_class
        prefix = respond_to?(:model_name) ? model_name : name
        decorator_name = "#{prefix}Decorator"
        decorator_name.constantize
      rescue NameError => e
        if superclass.respond_to?(:decorate_class)
          klass = Class.new(superclass.decorate_class)
          Object.const_set(decorator_name, klass)
        else
          raise unless e.missing_name?(decorator_name)
          raise Draper::UninferrableDecoratorError, self
        end
      end
    end
  end
end
