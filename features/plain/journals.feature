Feature: Editing journals
  As an editor of AntCat
  I want to change the titles of journals
  So that they are correct

  Scenario: Not logged in
    When I go to the references page
    Then I should not see "Journals"

  Scenario: Logged in
    Given I am logged in
    When I go to the references page
    When I follow "Journals"
    Then I should be on the "Edit journals" page
