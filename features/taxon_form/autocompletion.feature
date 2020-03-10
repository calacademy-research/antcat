# TODO: Fix. Skipped because this happens from time to time:
# (::) failed steps (::)
# One or more errors were raised in the Javascript code on the page. If you don't care about these errors, you can ignore them by setting # js_errors: false in your Apparition configuration (see documentation for details).
# ReferenceError: jQuery is not defined
#     at <anonymous>:13:19
#     at <anonymous>:13:43 (Capybara::Apparition::JavascriptError)
# ./features/support/cucumber_helpers/wait_for_jquery.rb:6:in `block (2 levels) in wait_for_jquery'
# ./features/support/cucumber_helpers/wait_for_jquery.rb:5:in `loop'
# ./features/support/cucumber_helpers/wait_for_jquery.rb:5:in `block in wait_for_jquery'
# ./features/support/cucumber_helpers/wait_for_jquery.rb:4:in `wait_for_jquery'
# ./features/step_definitions/typeahead_autocomplete_steps.rb:20:in `"I start filling in {string} with {string}"'
# features/taxon_form/autocompletion.feature:12:in `And I start filling in ".locality-autocomplete-js-hook" with "M"'
# Failing Scenarios:
# cucumber features/taxon_form/autocompletion.feature:7 # Scenario: Autocompleting protonym localities

@skip_ci @javascript
Feature: Autocompletion (taxon-related)
  Background:
    Given I log in as a catalog editor
    And there is a species "Atta major" in the genus "Atta"

  Scenario: Autocompleting protonym localities
    Given there is a genus with locality "Mexico"

    When I go to the catalog page for "Atta"
    And I follow "Add species"
    And I start filling in ".locality-autocomplete-js-hook" with "M"
    Then I should see the following autocomplete suggestions:
      | Mexico |
