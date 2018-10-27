Feature: Editing tooltips
  As an editor of AntCat
  I want to add and edit tooltips
  So that other editors can understand how to edit the catalog

  Background:
    Given I am logged in as a catalog editor

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
