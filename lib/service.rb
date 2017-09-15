# To make services callable like this:
# `ServiceObject[params]` instead of `ServiceObject.new(params).call`.

module Service
  extend ActiveSupport::Concern

  included do
    def self.[] *args
      new(*args).call
    end
  end
end
