# frozen_string_literal: true

require_relative '../../../features/support/reference_steps_helpers'

require_relative '../../../features/support/cucumber_helpers/paths'
require_relative '../../../features/support/cucumber_helpers/selectors'
require_relative '../../../features/support/cucumber_helpers/within_helpers'

# rubocop:disable all
# TODO: Remove (added so that Cucumber steps can be left as is while converting them to normal methods).
def Given(*); end
def When(*); end
def Then(*); end
def And(*); end
# rubocop:enable all

Dir[Rails.root.join("features/step_definitions/**/*.rb")].each { |f| require f }

module Features
  module StepHelpers
    include CucumberHelpers::Paths
    include CucumberHelpers::Selectors
    include CucumberHelpers::WithinHelpers
  end
end
