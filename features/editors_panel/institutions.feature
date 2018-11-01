Feature: Institutions
  Background:
    Given I am logged in as a catalog editor

  Scenario: Adding an institution
    When I go to the Editor's Panel
    And I follow "Edit institutions"
    Then I should not see "CASC"
    And I should not see "California Academy of Sciences"

    When I follow "New"
    And I fill in "institution_abbreviation" with "CASC"
    And I fill in "institution_name" with "California Academy of Sciences"
    And I press "Save"
    Then I should see "Successfully created institution"

    When I go to the institutions page
    Then I should see "CASC"
    And I should see "California Academy of Sciences"

  Scenario: Editing an institution
    Given there is an institution "CASC" ("California Academy of Sciences")

    When I go to the institutions page
    And I follow "CASC"
    And I follow "Edit"
    And I fill in "institution_abbreviation" with "SASC"
    And I fill in "institution_name" with "Sweden Academy of Sciences"
    And I press "Save"
    Then I should see "Successfully updated institution"

    When I go to the institutions page
    Then I should see "SASC"
    And I should see "Sweden Academy of Sciences"

  Scenario: Deleting an institution
    Given there is an institution "CASC" ("California Academy of Sciences")

    When I go to the institutions page
    Then I should not see "Delete"

    When I log in as a superadmin
    And I go to the institutions page
    Then I should see "CASC"

    When I follow "Delete"
    Then I should be on the institutions page
    And I should see "Institution was successfully deleted"
    And I should not see "CASC"
