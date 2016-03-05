Feature: Editing journals
  As an editor of AntCat
  I want to change the titles of journals
  So that they are correct

  Scenario: Logged in
    Given I am logged in
    And a journal exists with a name of "Psyche"
    When I go to the references page
    And I follow "Journals"
    Then I should be on the "journals index" page

  Scenario: Edit a journal name
    Given I am logged in
    And a journal exists with a name of "Psyche"
    When I go to the references page
    And I follow "Journals"
    And I follow "Psyche"
    And I follow "Edit journal name"
    And I fill in "journal_name" with "Science"
    And I press "Save"
    Then I should see "Successfully updated journal"
    When I go to the references page
    And I follow "Journals"
    Then I should see "Science"

  Scenario: Edit a journal name without logging in
    Given a journal exists with a name of "Psyche"
    When I go to the "journals index" page
    And I follow "Psyche"
    Then I should not see "Edit journal name"