Feature: Signing up
  As an internet user
  I want to register an AntCat account
  So that I can improve the database

  Scenario: Sign up
    When I go to the sign up page
    And I fill in "user_email" with "pizza@example.com" within "#page_contents"
    And I fill in "user_password" with "secret123" within "#page_contents"
    And I fill in "user_password_confirmation" with "secret123" within "#page_contents"
    And I press "Sign up"
    Then I should be on the users page
    And I should see "Welcome! You have signed up successfully."
    And I should see "pizza@example.com"
