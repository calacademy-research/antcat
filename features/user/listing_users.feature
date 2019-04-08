Feature: Listing users
  Background:
    Given this user exists
      | email              | name     | password |
      | quintus@antcat.org | Batiatus | secret   |

  Scenario: Listing AntCat users
    When I go to the users page
    Then I should see "Batiatus"
    And I should see "quintus@antcat.org"
