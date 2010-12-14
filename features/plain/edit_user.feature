Feature: Editing a user
  As a user of ANTBIB
  I want to edit my password and email
  So that I can use a password that makes sense
    And so I can use a different email than what I was signed up with

  Scenario: Changing my password
    Given I am logged in
    When I go to the main page
      And I follow "mark1@example.com"
    Then I should be on the edit user page
    When I fill in "user_password" with "new password"
      And I fill in "user_password_confirmation" with "new password"
      And I fill in "user_current_password" with "secret"
      And I press "Update"
    Then I should be on the main page
      And I should see "Your account has been updated"
    When I follow "sign out"
    Then I should not see "mark1@example.com"
    When I follow "sign in"
      And I fill in "user_email" with "mark1@example.com"
      And I fill in "user_password" with "new password"
      And I press "Sign in"
    Then I should be on the main page
      And I should see "mark1@example.com"
