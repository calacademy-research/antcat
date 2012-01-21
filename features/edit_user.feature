@dormant
Feature: Editing a user
  As a user of AntCat
  I want to edit my password and email
  So that I can use a password that makes sense
    And so I can use a different email than what I was signed up with

  Scenario: Changing my password
    Given I am logged in
    When I go to the main page
      And I follow "mark@example.com"
    Then I should be on the edit user page
    When I fill in "user_password" with "new password" within "#page_contents"
      And I fill in "user_password_confirmation" with "new password" within "#page_contents"
      And I fill in "user_current_password" with "secret" within "#page_contents"
      And I press "Update"
    Then I should be on the main page
      And I should see "Your account has been updated"
    When I follow "Logout"
    Then I should not see "mark@example.com"
    When I follow "Login"
      And I fill in "user_email" with "mark@example.com"
      And I fill in "user_password" with "new password"
      And I press "Go" within "#login"
    Then I should be on the main page
      And I should see "mark@example.com"
