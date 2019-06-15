Feature: Feed (taxa)
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Added taxon (with edit summary)
    Given there is a subfamily "Formicinae"
    And this reference exists
      | author | citation_year |
      | Fisher | 2004          |
    And the default reference is "Fisher, 2004"

    When I go to the catalog page for "Formicinae"
    And I follow "Add genus"
    And I set the name to "Atta"
    And I set the protonym name to "Atta"
    And I fill in "taxon_protonym_attributes_authorship_attributes_pages" with "page 35"
    And I fill in "edit_summary" with "fix typo"
    And I press "Save"
    And I go to the activity feed
    Then I should see "Archibald added the genus Atta to the subfamily Formicinae" and no other feed items
    And I should see the edit summary "fix typo"

  Scenario: Edited taxon (with edit summary)
    Given there is a subfamily "Antcatinae"

    When I go to the edit page for "Antcatinae"
    And I fill in "edit_summary" with "fix typo"
    And I save the taxon form
    And I go to the activity feed
    Then I should see "Archibald edited the subfamily Antcatinae" and no other feed items
    And I should see the edit summary "fix typo"

  Scenario: Deleted taxon
    Given there is a subfamily "Antcatinae"

    When I go to the catalog page for "Antcatinae"
    And I follow "Delete"
    And I go to the activity feed
    Then I should see "Archibald deleted the subfamily Antcatinae" and no other feed items
