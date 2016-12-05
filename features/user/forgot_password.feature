Feature: Forgot password
  As a user of AntCat
  I want to be able to get onto the site even if I forget my password

  Scenario: Visiting the forgot password page
    Given I am not logged in

    When I go to the main page
    And I follow the first "Login"
    And I follow "Forgot password"
    Then I should see "Send me reset password instructions"
