Feature: Forgot password
  As a user of AntCat
  I want to be able to get onto the site even if I forget my password

  Scenario: Visiting the forgot password page
    Given I am not logged in
    When I go to the main page
    And I follow the first "Login"
    And I follow "Forgot password"
    Then I should be on the forgot password page

  Scenario: Visiting the forgot password page after a failed login attempt
    Given PENDING: JS login disabled
    Given I am not logged in
    * I go to the main page
    * I follow the first "Login"
    * I fill in the email field with "email@example.com"
    * I fill in the password field with "asd;fljl;jsdfljsdfj"
    * I press the first "Go" to log in
    * I follow "forgot password"
    Then I should be on the forgot password page
