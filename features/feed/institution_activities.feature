@feed
Feature: Feed (institutions)
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Added institution
    When I go to the institutions page
    And I follow "New"
    And I fill in "institution_abbreviation" with "CASC"
    And I fill in "institution_name" with "California Academy of Sciences"
    And I fill in "edit_summary" with "fix typo"
    And I press "Save"
    And I go to the activity feed
    Then I should see "Archibald added the institution CASC" and no other feed items
    And I should see the edit summary "fix typo"

  Scenario: Edited institution
    Given there is an institution "CASC" ("California Academy of Sciences")

    When I go to the institutions page
    And I follow "CASC"
    And I follow "Edit"
    And I fill in "institution_abbreviation" with "SASC"
    And I fill in "institution_name" with "Sweden Academy of Sciences"
    And I fill in "edit_summary" with "fix typo"
    And I press "Save"
    And I go to the activity feed
    Then I should see "Archibald edited the institution SASC" and no other feed items
    And I should see the edit summary "fix typo"

  Scenario: Deleted institution
    Given there is an institution "CASC" ("California Academy of Sciences")
    And I log in as a superadmin named "Archibald"

    When I go to the institutions page
    And I follow "Delete"
    And I go to the activity feed
    Then I should see "Archibald deleted the institution CASC" and no other feed items
