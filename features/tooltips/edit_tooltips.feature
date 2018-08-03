Feature: Editing tooltips
  As an editor of AntCat
  I want to add and edit tooltips
  So that other editors can understand how to edit the catalog

  Background:
    Given I am logged in

  Scenario: Listing all tooltips
    Given this tooltip exist
      | key      | key_enabled | text        | scope        |
      | selector | true        | Is enabled! | widget_tests |

    When I go to the tooltips editing page
    Then I should see "Edit Tooltips"
    And I should see "Is enabled!"

  @javascript
  Scenario: Hovering a tooltip
    Given this tooltip exists
      | key       | key_enabled | text      | scope        |
      | hardcoded | true        | A tooltip | widget_tests |

    When I go to the tooltips test page
    Then I should not see the tooltip text "A tooltip"

    When I hover the tooltip next to the text "Hardcoded"
    Then I should see the tooltip text "A tooltip"

  @javascript
  Scenario: Adding a key-based tooltip
    When I go to the tooltips test page
    And I hover the tooltip next to the text "Hardcoded"
    Then I should see the tooltip text "Could not find tooltip with key 'hardcoded'"

    When I go to the tooltips editing page
    And I follow "New Tooltip"
      And I fill in "tooltip[key]" with "hardcoded"
      And I fill in "tooltip[scope]" with "widget_tests"
      And I fill in "tooltip[text]" with "Text used in the tooltip"
      And I follow "Hide/show advanced"
      And I check "tooltip[key_enabled]"
    And I press "Create Tooltip"
    And I wait
    And I go to the tooltips test page
    And I hover the tooltip next to the text "Hardcoded"
    Then I should see the tooltip text "Text used in the tooltip"

  @javascript @no_travis
  Scenario: Editing a selector-based tooltip
    Given this tooltip exists
      | key      | text      | selector | selector_enabled | scope        |
      | whatever | Typo oops | li.title | true             | widget_tests |

    When I go to the tooltips test page
    And I refresh the page (JavaScript)
    Then I should not see the tooltip text "Typo oops"

    When I hover the tooltip next to the element containing "Hook"
    Then I should see the tooltip text "Typo oops"

    When I go to the tooltips editing page
    And I follow "whatever"
    And I fill in "tooltip[text]" with "A title"
    And I press "Update Tooltip"
    And I go to the tooltips test page
    And I refresh the page (JavaScript)
    Then I should not see the tooltip text "Typo oops"
    And I should not see the tooltip text "A title"

    When I hover the tooltip next to the element containing "Hook"
    Then I should see the tooltip text "A title"

  @javascript
  Scenario: Disabling a key-based tooltip
    Given this tooltip exist
      | key       | key_enabled | text       | scope        |
      | hardcoded | true        | Is enabled | widget_tests |

    When I go to the tooltips test page
    Then I should not see the tooltip text "Is enabled"

    When I hover the tooltip next to the text "Hardcoded"
    Then I should see the tooltip text "Is enabled"

    When I go to the tooltips editing page
      And I follow "hardcoded"
      And I follow "Hide/show advanced"
      And I wait
      And I uncheck "tooltip[key_enabled]"
    And I press "Update Tooltip"
    And I wait
    And I go to the tooltips test page
    Then I should not see any tooltips next to the text "Hardcoded"

  @javascript @no_travis
  Scenario: Disabling a selector-based tooltip
    Given this tooltip exists
      | key      | text    | selector | selector_enabled | scope         |
      | whatever | A title | li.title | true             | widget_tests  |

    When I go to the tooltips test page
    And I refresh the page (JavaScript)
    And I hover the tooltip next to the element containing "Hook"
    Then I should see the tooltip text "A title"

    When I go to the tooltips editing page
    And I follow "whatever"
    And I follow "Hide/show advanced"
    And I wait
    And I uncheck "tooltip[selector_enabled]"
    And I press "Update Tooltip"
    And I wait
    And I go to the tooltips test page
    And I refresh the page (JavaScript)
    Then I should not see any tooltips next to the element containing "Hook"

  @javascript
  Scenario: Page based exclusion works
    When I go to the tooltips editing page
    And I hover the tooltip next to the text "Tooltip text"
    Then I should see the tooltip text "Could not find tooltip with key 'text'"

    When I follow "New Tooltip"
    And I fill in "tooltip[key]" with "text"
    And I follow "Hide/show advanced"
    And I check "tooltip[key_enabled]"
    And I fill in "tooltip[scope]" with "tooltips2"
    And I fill in "tooltip[text]" with "Text used in the tooltip"
    And I press "Create Tooltip"
    And I wait
    And I go to the tooltips editing page
    And I hover the tooltip next to the text "Tooltip text"
    Then I should not see the tooltip text "Text used in the tooltip"

  @javascript
  Scenario: Toggle i helpers
    When I go to the tooltips editing page
    And I follow "Show tooltips helper"
    Then I should see "Hide tooltips helper"

    When I follow "Hide tooltips helper"
    Then I should see "Show tooltips helper"
