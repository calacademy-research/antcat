Feature: Logging in
  As a user of AntCat
  I want to be able to log in
  So I can edit references

  Background:
    Given this user exists
      | email             | password | password_confirmation |
      | email@example.com | secret   | secret                |

  @javascript
  Scenario: Logging in successfully from the login page
    Given I am not logged in
    * I go to the login page
    * I fill in the email field with "email@example.com"
    * I fill in the password field with "secret"
    * I press "Log in"
    Then I should be on the main page

  @javascript
  Scenario: Logging in successfully from the main page
    Given I am not logged in
    * I go to the main page
    * I follow "Login"
    * I fill in the email field with "email@example.com"
    * I fill in the password field with "secret"
    * I press "Go" to log in
    Then I should be on the main page

  Scenario: Logging in unsuccessfully
    Given I am not logged in
    * I go to the main page
    * I follow "Login"
    * I fill in the email field with "email@example.com"
    * I fill in the password field with "asd;fljl;jsdfljsdfj"
    * I press "Go" to log in
    Then I should be on the login page

  Scenario: Forgot password
    Given I am not logged in
    * I go to the main page
    * I follow "Login"
    * I fill in the email field with "email@example.com"
    * I fill in the password field with "asd;fljl;jsdfljsdfj"
    * I press "Go" to log in
    * I follow "forgot password"
    Then I should be on the forgot password page

  @javascript
  Scenario: Returning to previous page
    Given I am not logged in
    * I go to the references page
    * I follow "Login"
    * I fill in the email field with "email@example.com"
    * I fill in the password field with "secret"
    * I press "Go" to log in
    Then I should be on the references page
