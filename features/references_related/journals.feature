@feed
Feature: Editing journals
  Background:
    Given I log in as a catalog editor named "Archibald"
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

    When I go to the activity feed
    Then I should see "Archibald edited the journal Science (changed journal name from Psyche)" and no other feed items

  Scenario: Deleting an unused journal
    When I follow "Delete"
    Then I should see "Journal was successfully deleted"

    When I go to the references page
    And I follow "Journals"
    Then I should not see "Psyche"

    When I go to the activity feed
    Then I should see "Archibald deleted the journal Psyche" and no other feed items
