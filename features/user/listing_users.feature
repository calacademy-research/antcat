Feature: Listing users
  Background:
    Given this user exists
      | email              | name     |
      | quintus@antcat.org | Batiatus |

  Scenario: Listing AntCat users
    When I go to the users page
    Then I should see "Batiatus"
    And I should see "quintus@antcat.org"
