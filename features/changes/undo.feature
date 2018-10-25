@papertrail
Feature: Workflow
  As an editor of AntCat
  I want to change a taxon's parent
  and then undo that change
  so mistakes can be repaired

  Background:
    Given there is a subfamily "Formicinae"
    And I log in as a catalog editor named "Mark Wilden"

  @javascript
  Scenario: Changing a taxon and seeing it on the Changes page, undoing it
    When I go to the edit page for "Formicinae"
    And I fill in "taxon_headline_notes_taxt" with "asdfgh"
    And I press "Save"
    And I go to the catalog page for "Formicinae"
    Then I should see "This taxon has been changed; changes awaiting approval"
    And I should see "asdfgh"

    When I go to the changes page
    Then I should see "Mark Wilden changed Formicinae"

    When I follow "Undo..."
    Then I should see "This undo will roll back the following changes"
    And I should see "Formicinae"
    And I should see "changed by Mark Wilden"

    When I press "Undo!"
    Then I should not see "Formicinae"

    When I go to the catalog page for "Formicinae"
    Then I should not see "asdfgh"

  @javascript
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
    And I press "Save"
    And I go to the changes page
    Then I should see "Becton"
    And I should see "major"

    # Change parent from B -> C
    When I go to the edit page for "Becton major"
    And I click the parent name field
    And I set the parent name to "Chatsworth"
    And I press "OK"
    Then I should see "Would you like to create a new combination under this parent?"

    When I press "Yes, create new combination"
    Then the name button should contain "Chatsworth major"

    When I press "Save"
    # We are now on the catalog page after doing A -> B -> C
    Then I should be on the catalog page for "Chatsworth major"
    And the name in the header should be "Chatsworth major"

    When I go to the catalog page for "Atta major"
    Then I should see "see Chatsworth major"

    When I go to the catalog page for "Becton major"
    Then I should see "an obsolete combination of Chatsworth major"

    When I go to the changes page
    And I follow the first "Undo..."
    Then I should see "This undo will roll back the following changes"

    When I press "Undo!"
    Then I should see "Becton"
    And I should see "major"
    And I should not see "Chatsworth"

    When I go to the catalog page for "Becton major"
    Then I should see "Becton major" in the header

    When I go to the changes page
    And I follow the first "Undo..."
    Then I should see "This undo will roll back the following changes"

    When I press "Undo!"
    Then I should not see "Becton"
    And I should not see "major"
    And I should not see "Chatsworth"

    When I go to the catalog page for "Atta major"
    Then I should see "Atta major" in the header

  @javascript
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
    And I press "Save"
    And I go to the changes page
    Then I should see "Becton"
    And I should see "major"

    # Change parent from B -> C
    When I go to the edit page for "Becton major"
    And I click the parent name field
    And I set the parent name to "Chatsworth"
    And I press "OK"
    Then I should see "Would you like to create a new combination under this parent?"

    When I press "Yes, create new combination"
    Then the name button should contain "Chatsworth major"

    When I press "Save"
    And I go to the changes page
    And I follow the second "Undo..."
    Then I should see "This undo will roll back the following changes"

    When I press "Undo!"
    Then I should not see "Becton"
    And I should not see "major"
    And I should not see "Chatsworth"

    When I go to the catalog page for "Atta major"
    Then I should see "Atta major" in the header

    # TODO: test this where we undo the oldest and then both are gone.

  Scenario: Deleting a subfamily with genera and undoing the change
    Given the Formicidae family exists
    And I log in as a superadmin
    And there is a subfamily "Ancatinae"
    And tribe "Antcatini" exists in that subfamily
    And genus "Antcatia" exists in that tribe
    And genus "Tactania" exists in that tribe

    When I go to the catalog page for "Ancatinae"
    Then I should see "Antcatini"
    And I should see "Antcatia"
    And I should see "Tactania"

    When I go to the catalog page for "Antcatini"
    Then I should see "Antcatia"
    And I should see "Tactania"

    When I follow "Delete..."
    And I follow "Confirm and delete"
    And I go to the catalog page for "Ancatinae"
    Then I should not see "Antcatini"
    And I should not see "Antcatia"
    And I should not see "Tactania"

    When I go to the changes page
    And I follow the first "Undo..."
    And I press "Undo!"
    And I go to the catalog page for "Ancatinae"
    Then I should see "Antcatini"
    And I should see "Antcatia"
    And I should see "Tactania"
