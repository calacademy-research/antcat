Feature: Editing tooltips
  As an editor of AntCat
  I want to add and edit tooltips
  So that editing the catalog becomes easier

  Background:
    Given I am logged in
    And these tooltips exist
      | key               | text                 |
      | tooltips.key      | Used for namespacing |
      | tooltips.selector | jQuery selector      |

  Scenario: Listing all tooltips
    When I go to the tooltips editing page
    Then I should see "Edit Tooltips"
    Then I should see "jQuery selector"

  @javascript
  Scenario: Hovering a hard-coded tooltip
    When I go to the tooltips editing page
    Then I follow "tooltips.key"
    Then I should see "Used for namespacing"
    And I should not see "jQuery selector"

    When I hover the the tooltip within "Selector"
    Then I should see "jQuery selector"

  @javascript
  Scenario: Hovering a selector-based tooltip
    When I go to the tooltips editing page
    Then I follow "tooltips.key"
    Then I should not see "Test title"

    Given this tooltip also exists
      | key        | text       | selector                        | selector_enabled |
      | test.title | Test title | a[data-confirm="Are you sure?"] | true             |
    When I reload the page
    Then I should not see "Test title"

    When I hover the the tooltip next to "Destroy"
    Then I should see "Test title"
