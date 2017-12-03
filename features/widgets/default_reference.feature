@javascript
Feature: Using the default reference
  Background:
    Given I am logged in
    And this reference exists
      | author     | title          | year | citation   |
      | Ward, P.S. | Annals of Ants | 2010 | Psyche 1:1 |

  Scenario: Default reference used for new taxon
    Given there is a genus "Atta"
    And the default reference is "Ward 2010"

    When I go to the catalog page for "Atta"
    And I follow "Add species"
    Then the authorship should contain the reference "Ward 2010"

  Scenario: Using the default reference in the reference popup
    Given the default reference is "Ward 2010"

    When I go to the reference popup widget test page
    And I wait
    And I wait
    And I press "Ward, 2010"
    Then the current reference should be "Ward, P.S. 2010. Annals of Ants. Psyche 1:1."

  Scenario: Don't show the button if there's no default
    Given there is no default reference

    When I go to the reference popup widget test page
    And I wait
    Then I should not see the default reference button

  Scenario: Seeing the default reference button on the taxt editor
    Given the default reference is "Ward 2010"

    When I go to the taxt editor test page
    And I hack the taxt editor in test env
    And I press "Ward, 2010"
    Then the taxt editor should contain the editable taxt for "Ward 2010 "

  Scenario: Cancelling after choosing the default reference
    Given the default reference is "Ward 2010"

    When I go to the reference field test page
    And I click the reference field
    And I press "Ward, 2010"
    And I wait
    And I press "Cancel"
    Then the authorship field should contain "(none)"
