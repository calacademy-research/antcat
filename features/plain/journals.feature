Feature: Editing journals
  As an editor of AntCat
  I want to change the titles of journals
  So that they are correct

  Scenario: Not logged in
    When I go to the main page
    Then I should not see "Edit journals"

  Scenario: Logged in
    Given I am logged in
    When I go to the main page
    When I follow "Edit journals"
    ehen I should be on the "Edit journals" page
