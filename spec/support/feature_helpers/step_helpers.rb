# frozen_string_literal: true

Dir[Rails.root.join("spec/support/feature_helpers/steps/**/*.rb")].each { |f| require f }

module FeatureHelpers
  module StepHelpers
    include FeatureHelpers::Paths
    include FeatureHelpers::Selectors
    include FeatureHelpers::Steps
  end
end
