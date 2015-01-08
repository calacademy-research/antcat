@javascript
Feature: Workflow
  As an editor of AntCat
  I want to change a taxon's parent
  and then undo that change
  so mistakes can be repaired

  Background:
    Given these references exist
      | authors | citation   | title | year |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |
    And there is a subfamily "Formicinae"
    And there is a genus "Eciton"
    And version tracking is enabled
    And I log in as a catalog editor

  Scenario: Changing a taxon and seeing it on the Changes page, undoing it
    When I go to the catalog page for "Formicinae"
    * I press "Edit"
    * I fill in "taxon_headline_notes_taxt" with "asdfgh"
    * I save my changes
    * I go to the catalog page for "Formicinae"
    Then I should see "This taxon has been changed and is awaiting approval"
    * I should see the name "Formicinae" in the changes
    When I go to the changes page
    Then I should see "Formicinae"
    And I should see "Mark Wilden changed Formicinae"
    * I should see the notes "asdfgh" in the changes
    When I press "Undo"
    Then I should see an alert box
    Then I should not see "Formicinae"
    And I should not see "asdfgh"
    When I go to the catalog page for "Formicinae"
    Then I should not see "asdfgh"

  # This test is long. It may be worth doing all the data setup
  # required to get these preconditions without going through the UI.
  Scenario: Changing a species's genus twice by using the helper link
    Given there is an original species "Atta major" with genus "Atta"
    And there is a genus "Becton"
    And there is a genus "Chatsworth"

   # Change parent from A -> B
    When I go to the edit page for "Atta major"
    And I click the parent name field
    And I set the parent name to "Becton"
    And I press "OK"
    Then I should see "Would you like to create a new combination under this parent?"
    When I press "Yes, create new combination"
    When I save my changes
    And I go to the changes page
    Then I should see the genus "Becton" in the changes
    * I should see the name "major" in the changes

   # Change parent from B -> C
    When I go to the edit page for "Becton major"
    And I click the parent name field
    And I set the parent name to "Chatsworth"
    And I press "OK"
    Then I should see "Would you like to create a new combination under this parent?"
    When I press "Yes, create new combination"
    Then the name field should contain "Chatsworth major"
    When I save my changes

   # We are now on the catalog page after doing A -> B -> C
    Then I should be on the catalog page for "Chatsworth major"
    And the name in the header should be "Chatsworth major"
    When I go to the catalog page for "Atta major"
    Then I should see "see Chatsworth major"
    When I go to the catalog page for "Becton major"
    Then I should see "an obsolete combination of Chatsworth major"

    When I go to the changes page
    And I click ".undo_button_2"
    Then I should see an alert box
    * I should see the genus "Becton" in the changes
    * I should see the name "major" in the changes
    And I should not see "Chatsworth"


    # test this where we undo the oldest and then both are gone
  # test this where we undo the most recent and then there is one, then the next most recent and there are none, and we're back to baseline.



