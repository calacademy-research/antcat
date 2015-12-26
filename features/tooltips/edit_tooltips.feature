Feature: Editing tooltips
  As an editor of AntCat
  I want to add and edit tooltips
  So that other editors can understand how to edit the catalog

  Background:
    Given I am logged in

  Scenario: Listing all tooltips
    Given this tooltip exist
      | key                       | key_enabled | text                    |
      | tooltips.selector_enabled | true        | Enable jQuery selector? |

    When I go to the tooltips editing page
    Then I should see "Edit Tooltips"
    And I should see "Enable jQuery selector?"

  @javascript
  Scenario: Hovering a tooltip
    Given this tooltip exists
      | key                       | key_enabled | text                    |
      | tooltips.selector_enabled | true        | Enable jQuery selector? |

    When I go to the tooltips editing page
    Then I should not see the tooltip text "Enable jQuery selector?"

    When I hover the tooltip within "Selector enabled\?"
    Then I should see the tooltip text "Enable jQuery selector?"

  @javascript
  Scenario: Adding a key-based tooltip
    When I go to the tooltips editing page
    And I hover the tooltip within "Tooltip text"
    Then I should see the tooltip text "Could not find tooltip with key 'tooltips.text'"

    Then I follow "New Tooltip"
    And I fill in "tooltip[key]" with "tooltips.text"
    And I check "tooltip[key_enabled]"
    And I fill in "tooltip[text]" with "Text used in the tooltip"
    Then I press "Create Tooltip"
    And I wait for a bit

    Then I go to the tooltips editing page
    When I hover the tooltip within "Tooltip text"
    Then I should see the tooltip text "Text used in the tooltip"

  @javascript
  Scenario: Editing a selector-based tooltip
    Given this tooltip exists
      | key        | text      | selector | selector_enabled |
      | test.title | Typo oops | h2.title | true             |

    When I go to the tooltips editing page
    Then I should not see the tooltip text "Typo oops"

    When I hover the tooltip next to "Edit Tooltips"
    Then I should see the tooltip text "Typo oops"

    Then I go to the tooltips editing page
    And I follow "test.title"

    Then I fill in "tooltip[text]" with "A title"
    And I press "Update Tooltip"
    And I wait for a bit

    When I go to the tooltips editing page
    Then I should not see the tooltip text "Typo oops"
    And I should not see the tooltip text "A title"

    When I hover the tooltip next to "Edit Tooltips"
    Then I should see the tooltip text "A title"

  @javascript
  Scenario: Disabling a key-based tooltip
    Given this tooltip exist
      | key                       | key_enabled | text                    |
      | tooltips.selector_enabled | true        | Enable jQuery selector? |

    When I go to the tooltips editing page
    Then I should not see the tooltip text "Enable jQuery selector?"

    When I hover the tooltip within "Selector enabled\?"
    Then I should see the tooltip text "Enable jQuery selector?"

    And I follow "tooltips.selector_enabled"

    Then I uncheck "tooltip[key_enabled]"
    And I press "Update Tooltip"
    And I wait for a bit

    When I go to the tooltips editing page
    Then I should not see any tooltips within "Selector enabled\?"

  @javascript
  Scenario: Disabling a selector-based tooltip
    Given this tooltip exists
      | key        | text    | selector | selector_enabled |
      | test.title | A title | h2.title | true             |

    When I go to the tooltips editing page
    And I wait for a bit

    When I hover the tooltip next to "Edit Tooltips"
    Then I should see the tooltip text "A title"

    And I follow "test.title"

    Then I uncheck "tooltip[selector_enabled]"
    And I press "Update Tooltip"
    And I wait for a bit

    When I go to the tooltips editing page
    Then I should not see any tooltips next to "A title"
