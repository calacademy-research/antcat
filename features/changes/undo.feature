@papertrail
Feature: Undo
  As an editor of AntCat
  I want to edit a taxon
  and then undo that change
  so mistakes can be repaired

  Background:
    Given there is a subfamily "Formicinae"
    And I log in as a catalog editor named "Mark Wilden"

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

  Scenario: Deleting a taxon and undoing the change
    Given the Formicidae family exists
    And there is a subfamily "Ancatinae"

    When I go to the catalog page for "Formicidae"
    Then I should see "Ancatinae"

    When I follow the first "Ancatinae"
    Given I will confirm on the next step
    And I follow "Delete"
    Then I should see "Taxon was successfully deleted."

    When I go to the catalog page for "Formicidae"
    Then I should not see "Ancatinae"

    When I go to the changes page
    And I follow the first "Undo..."
    And I press "Undo!"
    And I go to the catalog page for "Formicidae"
    Then I should see "Ancatinae"
