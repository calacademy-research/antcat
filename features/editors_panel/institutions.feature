Feature: Institutions
  Scenario: Adding an institution (with edit summary)
    Given I log in as a catalog editor named "Archibald"

    When I go to the Editor's Panel
    And I follow "Edit institutions"
    Then I should not see "CASC"
    And I should not see "California Academy of Sciences"

    When I follow "New"
    And I fill in "institution_abbreviation" with "CASC"
    And I fill in "institution_name" with "California Academy of Sciences"
    And I fill in "edit_summary" with "fix typo"
    And I press "Save"
    Then I should see "Successfully created institution"

    When I go to the institutions page
    Then I should see "CASC"
    And I should see "California Academy of Sciences"

    When I go to the activity feed
    Then I should see "Archibald added the institution CASC" within the feed
    And I should see the edit summary "fix typo"

  Scenario: Editing an institution (with edit summary)
    Given there is an institution "CASC" ("California Academy of Sciences")
    And I log in as a catalog editor named "Archibald"

    When I go to the institutions page
    And I follow "California Academy of Sciences"
    And I follow "Edit"
    And I fill in "institution_abbreviation" with "SASC"
    And I fill in "institution_name" with "Sweden Academy of Sciences"
    And I fill in "edit_summary" with "fix typo"
    And I press "Save"
    Then I should see "Successfully updated institution"

    When I go to the institutions page
    Then I should see "SASC"
    And I should see "Sweden Academy of Sciences"

    When I go to the activity feed
    Then I should see "Archibald edited the institution SASC" within the feed
    And I should see the edit summary "fix typo"

  Scenario: Deleting an institution (with feed)
    Given there is an institution "CASC" ("California Academy of Sciences")
    And I log in as a superadmin named "Archibald"

    When I go to the institutions page
    And I follow "California Academy of Sciences"
    And I follow "Delete"
    Then I should be on the institutions page
    And I should see "Institution was successfully deleted"
    And I should not see "CASC"

    When I go to the activity feed
    Then I should see "Archibald deleted the institution CASC" within the feed
