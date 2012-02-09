@dormant
Feature: Forgetting my password
  As a user of AntCat
  I want to be able to get onto the site even if I forget my password

  Scenario: Forgetting my password
    Given I am not logged in
    When I go to the main page
      And I follow "Login"
      And I follow "Forgot password"
    Then I should be on the forgot password page
