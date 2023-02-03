# frozen_string_literal: true

require_relative '../../../features/support/cucumber_helpers/paths'
require_relative '../../../features/support/cucumber_helpers/selectors'

Dir[Rails.root.join("spec/support/feature_helpers/steps/**/*.rb")].each { |f| require f }

module FeatureHelpers
  module StepHelpers
    include CucumberHelpers::Paths
    include CucumberHelpers::Selectors
    include FeatureHelpers::Steps
  end
end
