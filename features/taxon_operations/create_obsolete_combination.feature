@javascript
Feature: Create obsolete combination
  Background:
    Given I log in as a catalog editor named "Archibald"

  @feed
  Scenario: Creating a missing obsolete combination (and see it in the activity feed)
    Given a genus exists with a name of "Pyramica" and no subfamily
    And there is a species "Strumigenys ravidura"

    When I go to the catalog page for "Strumigenys ravidura"
    And I follow "Create obsolete combination"
    And I set the obsolete genus field to "Pyramica"
    And I press "Create!"
    Then I should be on the catalog page for "Pyramica ravidura"
    And the "genus" of "Pyramica ravidura" should be "Pyramica"

    When I go to the activity feed
    Then I should see "Archibald created the obsolete combination Pyramica ravidura" and no other feed items
