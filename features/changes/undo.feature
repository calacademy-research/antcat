@papertrail
Feature: Workflow
  As an editor of AntCat
  I want to edit a taxon
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
