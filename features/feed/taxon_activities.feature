Feature: Feed (taxa)
  Background:
    Given I log in as a catalog editor named "Archibald"

  @javascript
  Scenario: Added taxon (with edit summary)
    Given there is a subfamily "Formicinae"
    And this reference exists
      | author | citation_year |
      | Fisher | 2004          |
    And the default reference is "Fisher, 2004"

    When I go to the catalog page for "Formicinae"
      And I follow "Add genus"
        And I click the name field
          And I set the name to "Atta"
          And I press "OK"
        And I click the protonym name field
          And I press "OK"
        And I fill in "taxon_protonym_attributes_authorship_attributes_pages" with "page 35"
        And I fill in "edit_summary" with "fix typo"
        And WAIT_FOR_JQUERY
        And I press "Save"
    And I go to the activity feed
    Then I should see "Archibald added the genus Atta to the subfamily Formicinae" and no other feed items
    And I should see the edit summary "fix typo"

  Scenario: Edited taxon (with edit summary)
    Given there is a subfamily "Antcatinae"

    When I go to the catalog page for "Antcatinae"
    And I follow "Edit"
    And I fill in "edit_summary" with "fix typo"
    And I save the taxon form
    And I wait
    And I go to the activity feed
    Then I should see "Archibald edited the subfamily Antcatinae" and no other feed items
    And I should see the edit summary "fix typo"

  Scenario: Deleted taxon
    Given there is a subfamily "Antcatinae"

    When I go to the catalog page for "Antcatinae"
    And I follow "Delete"
    And I go to the activity feed
    Then I should see "Archibald deleted the subfamily Antcatinae" and no other feed items
