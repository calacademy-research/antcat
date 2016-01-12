@javascript
@allow_rescue
Feature: Workflow
  As an editor of AntCat
  I want to change a taxon's parent
  and then undo that change
  so mistakes can be repaired

  Background:
    # Formicidae is only explicitly required by 'Changing a taxon and seeing it on ...'
    # TODO leaving this here
    Given the Formicidae family exists
    Given these references exist
      | authors | citation   | title | year |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |
    And there is a subfamily "Formicinae"
    And version tracking is enabled
    And I log in as a catalog editor named "Mark Wilden"

  # Add these scenarios
  # test notes:
  # change something with children. Ensure they're hit. Undo it. Ensure they're moved back. verify with db to ensure this happened.
  # add two changes. Roll back the earlier change, ensure that the warning dialog box comes up listing the impact on the later change

  # modify species b
  # a - b - a' case
  # modify species b
  # undo first change to species b
  # see what happens!

  Scenario: Changing a taxon and seeing it on the Changes page, undoing it
    When I go to the catalog page for "Formicinae"
    * I press "Edit"
    * I fill in "taxon_headline_notes_taxt" with "asdfgh"
    * I save my changes
    * I go to the catalog page for "Formicinae"
    Then I should see "This taxon has been changed; changes awaiting approval"
    * I should see the name "Formicinae" in the changes
    When I go to the changes page
    Then I should see "Formicinae"
    And I should see "Mark Wilden changed Formicinae"
    * I should see the notes "asdfgh" in the changes
    When I press "Undo"
    Then I should see "This undo will roll back the following changes"
    And I should see "Formicinae"
    And I should see "changed by Mark Wilden"
    When I press "Undo!"
    Then I should not see "Formicinae"
    And I should not see "asdfgh"
    When I go to the catalog page for "Formicinae"
    Then I should not see "asdfgh"

  # This test is long. It may be worth doing all the data setup
  # required to get these preconditions without going through the UI.
  # Note: having this long test may be worthwhile; it caught a bug in
  # the data model setup that wouldn't have been caught by setting
  # up the data structures manually.
  #  this where we undo the most recent and then there is one,
  # then the next most recent and there are none, and we're back to baseline.

  Scenario: Changing a species's genus twice by using the helper link, undo twice
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
    Then the name button should contain "Chatsworth major"
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
    Then I should see "This undo will roll back the following changes"
    When I press "Undo!"
    * I should see the genus "Becton" in the changes
    * I should see the name "major" in the changes
    And I should not see "Chatsworth"

    When I go to the catalog page for "Becton major"
    Then I should see "Becton major" in the header

    When I go to the changes page
    Then I click ".undo_button_1"
    Then I should see "This undo will roll back the following changes"
    When I press "Undo!"
    * I should not see "Becton"
    * I should not see "major"
    And I should not see "Chatsworth"

    When I go to the catalog page for "Atta major"
    Then I should see "Atta major" in the header

  Scenario: Changing a species's genus twice by using the helper link, undo oldest, restored to original condition.
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
    Then the name button should contain "Chatsworth major"
    When I save my changes

    When I go to the changes page
    When I click ".undo_button_1"
    Then I should see "This undo will roll back the following changes"
    When I press "Undo!"
    * I should not see "Becton"
    * I should not see "major"
    And I should not see "Chatsworth"

    When I go to the catalog page for "Atta major"
    Then I should see "Atta major" in the header

    # test this where we undo the oldest and then both are gone

  # Add scenario - add a new species, delete it, undo the delete
  # Same as above, with notes
