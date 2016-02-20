Feature: Logging in
  As a user of AntCat
  I want to be able to log in
  So I can edit references

  Background:
    Given this user exists
      | email             | name    | password | password_confirmation |
      | email@example.com | Quintus | secret   | secret                |

  @javascript
  Scenario: Logging in successfully from the login page
    Given I am not logged in
    * I go to the login page
    * I fill in the email field with "email@example.com"
    * I fill in the password field with "secret"
    * I press "Login"
    Then I should be on the main page

  @javascript
  Scenario: Logging in successfully from the main page
    Given PENDING: JS login disabled
    Given I am not logged in
    * I go to the main page
    * I follow "Login"
    * I fill in the email field with "email@example.com"
    * I fill in the password field with "secret"
    * I press the first "Go" to log in
    Then I should be on the main page

  @javascript
  Scenario: Logging in unsuccessfully
    Given I am not logged in
    * I go to the main page
    * I follow "Login"
    * I fill in the email field with "email@example.com"
    * I fill in the password field with "asd;fljl;jsdfljsdfj"
    * I press "Login"
    Then I should be on the login page

  Scenario: Returning to previous page
    Given I am not logged in
    * I go to the references page
    * I follow "Login"
    * I fill in the email field with "email@example.com"
    * I fill in the password field with "secret"
    * I press "Login"
    Then I should be on the references page
