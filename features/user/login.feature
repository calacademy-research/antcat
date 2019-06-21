Feature: Logging in
  Scenario: Logging and returning to previous page
    Given this user exists
      | email              | name     | password |
      | quintus@antcat.org | Batiatus | secret   |

    When I go to the references page
    Then I should not see "Logout"

    When I follow the first "Login"
    And I fill in "user_email" with "quintus@antcat.org"
    And I fill in "user_password" with "secret"
    And I press "Login"
    Then I should be on the references page
    And I should see "Logout"

  Scenario: Logging in unsuccessfully
    When I go to the main page
    And I follow the first "Login"
    And I fill in "user_email" with "quintus@antcat.org"
    And I fill in "user_password" with "asd;fljl;jsdfljsdfj"
    And I press "Login"
    Then I should be on the login page

  Scenario: Logging with a locked account
    Given this user exists
      | email              | name     | password | locked |
      | quintus@antcat.org | Batiatus | secret   | true   |

    When I go to the main page
    And I follow the first "Login"
    And I fill in "user_email" with "quintus@antcat.org"
    And I fill in "user_password" with "secret"
    And I press "Login"
    Then I should be on the login page
    And I should see "Your account has not been activated yet, or it been deactivated"
