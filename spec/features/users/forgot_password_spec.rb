Feature: Forgot password
  As a user of AntCat
  I want to be able to get onto the site even if I forget my password

  Background:
    Given these Settings: email: { enabled: true }

  Scenario: Visiting the forgot password page
    When I go to the main page
    And I follow "Login" within the desktop menu
    And I follow "Forgot password"
    Then I should see "Send me reset password instructions"
