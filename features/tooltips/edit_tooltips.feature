Feature: Editing tooltips
  As an editor of AntCat
  I want to add and edit tooltips
  So that other editors can understand how to edit the catalog

  Background:
    Given I am logged in

  Scenario: Listing all tooltips
    Given this tooltip exist
      | key           | key_enabled | text        |
      | test.selector | true        | Is enabled! |

    When I go to the tooltips editing page
    Then I should see "Edit Tooltips"
    And I should see "Is enabled!"

  @javascript
  Scenario: Hovering a tooltip
    Given this tooltip exists
      | key            | key_enabled | text      |
      | test.hardcoded | true        | A tooltip |

    When I go to the tooltips test page
    Then I should not see the tooltip text "A tooltip"

    When I hover the tooltip next to the text "Hardcoded"
    Then I should see the tooltip text "A tooltip"

  @javascript
  Scenario: Adding a key-based tooltip
    When I go to the tooltips test page
    And I hover the tooltip next to the text "Hardcoded"
    Then I should see the tooltip text "Could not find tooltip with key 'test.hardcoded'"

    Then I go to the tooltips editing page
    And I follow "New Tooltip"
    And I fill in "tooltip[key]" with "test.hardcoded"
    And I check "tooltip[key_enabled]"
    And I fill in "tooltip[text]" with "Text used in the tooltip"
    Then I press "Create Tooltip"
    And I wait for a bit

    Then I go to the tooltips test page
    When I hover the tooltip next to the text "Hardcoded"
    Then I should see the tooltip text "Text used in the tooltip"

  @javascript
  Scenario: Editing a selector-based tooltip
    Given this tooltip exists
      | key           | text      | selector | selector_enabled |
      | test.whatever | Typo oops | li.title | true             |

    When I go to the tooltips test page
    Then I should not see the tooltip text "Typo oops"

    When I hover the tooltip next to the element containing "Hook"
    Then I should see the tooltip text "Typo oops"

    Then I go to the tooltips editing page
    And I follow "test.whatever"

    Then I fill in "tooltip[text]" with "A title"
    And I press "Update Tooltip"
    And I wait for a bit

    When I go to the tooltips test page
    Then I should not see the tooltip text "Typo oops"
    And I should not see the tooltip text "A title"

    When I hover the tooltip next to the element containing "Hook"
    Then I should see the tooltip text "A title"

  @javascript
  Scenario: Disabling a key-based tooltip
    Given this tooltip exist
      | key            | key_enabled | text       |
      | test.hardcoded | true        | Is enabled |

    When I go to the tooltips test page
    Then I should not see the tooltip text "Is enabled"

    When I hover the tooltip next to the text "Hardcoded"
    Then I should see the tooltip text "Is enabled"

    Then I go to the tooltips editing page
    And I follow "test.hardcoded"

    Then I uncheck "tooltip[key_enabled]"
    And I press "Update Tooltip"
    And I wait for a bit

    When I go to the tooltips test page
    Then I should not see any tooltips next to the text "Hardcoded"

  @javascript
  Scenario: Disabling a selector-based tooltip
    Given this tooltip exists
      | key           | text    | selector | selector_enabled |
      | test.whatever | A title | li.title | true             |

    When I go to the tooltips test page
    And I wait for a bit
    When I hover the tooltip next to the element containing "Hook"
    Then I should see the tooltip text "A title"

    Then I go to the tooltips editing page
    And I wait for a bit
    And I follow "test.whatever"

    Then I uncheck "tooltip[selector_enabled]"
    And I press "Update Tooltip"
    And I wait for a bit

    Then I go to the tooltips test page
    Then I should not see any tooltips next to the element containing "Hook"
