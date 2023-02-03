# frozen_string_literal: true

Dir[Rails.root.join("spec/support/feature_helpers/**/*.rb")].each { |f| require f }

module FeatureHelpers
  module All
    include FeatureHelpers::Paths
    include FeatureHelpers::Selectors
    include FeatureHelpers::Steps
  end
end
