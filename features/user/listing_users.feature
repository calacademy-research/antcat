Feature: Listing users
  Background:
    Given this user exists
      | email             | name    | password | password_confirmation |
      | email@example.com | Quintus | secret   | secret                |

  Scenario: Listing all AntCat users
    When I go to the users page
    Then I should see "Quintus"
    And I should see "email@example.com"

  Scenario: Generating a list of all users' emails
    Given I am logged in

    When I go to the users page
    And I follow "All emails"
    Then I should see "User Emails"
    And I should see "Quintus"
    And I should see "<email@example.com>"

  Scenario: Only editors can browse the email list
    Given I am not logged in

    When I go to the users page
    Then I should not see "All emails"

    When I go to the user emails list
    Then I should see "Please log in before continuing"
