Feature: Feed (users)
  Scenario: User signed up
    When I go to the sign up page
      And I fill in "user_email" with "pizza@example.com"
      And I fill in "user_name" with "Quintus Batiatus"
      And I fill in "user_password" with "secret123"
      And I fill in "user_password_confirmation" with "secret123"
      And I press "Sign Up"
    And I go to the activity feed
    Then I should see "Quintus Batiatus registered an account, welcome to antcat.org!" and no other feed items
