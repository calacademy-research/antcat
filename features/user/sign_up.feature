Feature: Signing up
  Scenario: Sign up
    When I go to the sign up page
    And I fill in "user_email" with "pizza@example.com"
    And I fill in "user_name" with "Quintus Batiatus"
    And I fill in "user_password" with "secret123"
    And I fill in "user_password_confirmation" with "secret123"
    And I press "Sign Up"
    Then I should be on the main page
    And I should see "Welcome! You have signed up successfully."

    When I go to the activity feed
    Then I should see "Quintus Batiatus registered an account, welcome to antcat.org!"
