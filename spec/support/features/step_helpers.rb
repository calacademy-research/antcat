# frozen_string_literal: true

require_relative '../../../features/support/reference_steps_helpers'

require_relative '../../../features/support/cucumber_helpers/paths'
require_relative '../../../features/support/cucumber_helpers/selectors'
require_relative '../../../features/support/cucumber_helpers/within_helpers'

Dir[Rails.root.join("features/step_definitions/**/*.rb")].each { |f| require f }

module Features
  module StepHelpers
    include CucumberHelpers::Paths
    include CucumberHelpers::Selectors
    include CucumberHelpers::WithinHelpers
  end
end
