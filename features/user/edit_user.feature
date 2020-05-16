@skip_ci
Feature: Editing a user
  As a user of AntCat
  I want to edit my password and email

  Background:
    Given this user exists
      | email              | name     | password |
      | quintus@antcat.org | Batiatus | secret   |
    Given I log in as "Batiatus"

  Scenario: Changing password
    When I go to the main page
    And I follow "Batiatus" within the desktop menu
    And I follow "My account"
    And I fill in "user_password" with "new password"
    And I fill in "user_password_confirmation" with "new password"
    And I fill in "user_current_password" with "secret"
    And I press "Save"
    Then I should be on the main page
    And I should see "Your account has been updated"

    # Logging in with changed password.
    When I follow "Logout" within the desktop menu
    Then I should not see "Batiatus"

    When I follow "Login" within the desktop menu
    And I fill in "user_email" with "quintus@antcat.org"
    And I fill in "user_password" with "new password"
    And I press "Login"
    Then I should be on the main page
    And I should see "Batiatus"

  Scenario: Updating user details
    When I go to the main page
    Then I should see "Batiatus"
    And I should not see "Quintus, B."

    When I follow "Batiatus" within the desktop menu
    And I follow "My account"
    And I fill in "user_name" with "Quintus, B."
    And I fill in "user_current_password" with "secret"
    And I press "Save"
    Then I should be on the main page
    And I should see "Quintus, B."
    And I should not see "Batiatus"

  Scenario: Updating user preferences
    When I go to My account
    Then I should see "#user_settings_editing_helpers_create_combination" unchecked

    # Enable setting.
    When I check "user_settings_editing_helpers_create_combination"
    And I press "Save"
    Then I should see "Your account has been updated"

    When I go to My account
    Then I should see "#user_settings_editing_helpers_create_combination" checked
    And Batiatus' editing_helpers settings for create_combination should be "true" [Boolean]

    # Disable setting.
    When I uncheck "user_settings_editing_helpers_create_combination"
    And I press "Save"
    Then I should see "Your account has been updated"

    When I go to My account
    Then I should see "#user_settings_editing_helpers_create_combination" unchecked
    And Batiatus' editing_helpers settings for create_combination should be "false" [Boolean]
