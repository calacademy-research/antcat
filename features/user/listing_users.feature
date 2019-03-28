Feature: Listing users
  Background:
    Given this user exists
      | email             | name    | password |
      | email@example.com | Quintus | secret   |

  Scenario: Listing AntCat users
    When I go to the users page
    Then I should see "Quintus"
    And I should see "email@example.com"
