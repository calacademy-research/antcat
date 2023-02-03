# frozen_string_literal: true

require_relative '../../../features/support/cucumber_helpers/paths'
require_relative '../../../features/support/cucumber_helpers/selectors'

Dir[Rails.root.join("features/step_definitions/**/*.rb")].each { |f| require f }

module FeatureHelpers
  module StepHelpers
    include CucumberHelpers::Paths
    include CucumberHelpers::Selectors
  end
end
