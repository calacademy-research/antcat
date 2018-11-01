@no_travis
Feature: Editing a user
  As a user of AntCat
  I want to edit my password and email

  Scenario: Changing my password
    Given I am logged in

    When I go to the main page
    And I follow the first "Mark Wilden"
    And I follow "Change my password/name/email"
    And I fill in "user_password" with "new password"
    And I fill in "user_password_confirmation" with "new password"
    And I fill in "user_current_password" with "secret"
    And I press "Save"
    Then I should be on the main page
    And I should see "Your account has been updated"

    # Logging in with changed password.
    When I follow the first "Logout"
    Then I should not see "Mark Wilden"

    When I follow the first "Login"
      And I fill in the email field with my email address
      And I fill in "user_password" with "new password"
    And I press "Login"
    Then I should be on the main page
    And I should see "Mark Wilden"

  Scenario: Changing my name
    Given I am logged in

    When I go to the main page
    Then I should see "Mark Wilden"
    And I should not see "Brian Fisher"

    When I follow the first "Mark Wilden"
    And I follow "Change my password/name/email"
    And I fill in "user_name" with "Batiatus Q."
    And I fill in "user_current_password" with "secret"
    And I press "Save"
    Then I should be on the main page
    And I should see "Batiatus Q."
    And I should not see "Mark Wilden"
