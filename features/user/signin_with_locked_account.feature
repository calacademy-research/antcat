Feature: Logging in
  Background:
    Given this user exists
      | email              | name     | password | locked |
      | quintus@antcat.org | Batiatus | secret   | true   |

  Scenario: Logging with a locked account
    When I go to the main page
    And I follow the first "Login"
    And I fill in "user_email" with "quintus@antcat.org"
    And I fill in "user_password" with "secret"
    And I press "Login"
    Then I should be on the login page
    And I should see "Your account has not been activated yet, or it been deactivated"
