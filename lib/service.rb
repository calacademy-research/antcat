# frozen_string_literal: true

# To make services callable like this:
# `ServiceObject[params]` instead of `ServiceObject.new(params).call`.

module Service
  def self.included base
    base.extend(ClassMethods)
  end

  # TODO: For ruby 2.7, use:
  # ```
  #   module ClassMethods
  #     def [](...) # rubocop_disable Style/MethodDefParentheses
  #       new(...).call
  #     end
  #   end
  # ```

  module ClassMethods
    def [] *args
      new(*args).call
    end
  end
end
