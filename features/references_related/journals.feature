Feature: Editing journals
  As an editor of AntCat
  I want to change the titles of journals
  So that they are correct

  Background:
    Given I am logged in
    And a journal exists with a name of "Psyche"
    And I go to the references page
    And I follow "Journals"
    And I follow "Psyche"

  Scenario: Edit a journal's name
    When I follow "Edit journal name"
    And I fill in "journal_name" with "Science"
    And I press "Save"
    Then I should see "Successfully updated journal"

    When I go to the references page
    And I follow "Journals"
    Then I should see "Science"

  Scenario: Deleting an unused journal
    When I follow "Delete"
    Then I should see "Journal was successfully destroyed"

    When I go to the references page
    And I follow "Journals"
    Then I should not see "Psyche"
