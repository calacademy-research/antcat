@feed
Feature: Feed (taxa)
  Background:
    Given I log in as a catalog editor named "Archibald"

  @javascript
  Scenario: Added taxon (with edit summary)
    Given activity tracking is disabled
      And there is a subfamily "Formicinae"
      And this reference exists
        | author | citation_year |
        | Fisher | 2004          |
    And the default reference is "Fisher, 2004"
    And activity tracking is enabled

    When I go to the catalog page for "Formicinae"
      And I follow "Add genus"
        And I click the name field
          And I set the name to "Atta"
          And I press "OK"
        And I click the protonym name field
          And I press "OK"
        And I fill in "edit_summary" with "fix typo"
        And WAIT_FOR_JQUERY
        And I press "Save"
    And I go to the activity feed
    Then I should see "Archibald added the genus Atta to the subfamily Formicinae" and no other feed items
    And I should see the edit summary "fix typo"

  Scenario: Edited taxon (with edit summary)
    Given I add a taxon for the feed

    When I go to the catalog page for "Antcatinae"
    And I follow "Edit"
    And I fill in "edit_summary" with "fix typo"
    And I save the taxon form
    And I wait
    And I go to the activity feed
    Then I should see "Archibald edited the subfamily Antcatinae" and no other feed items
    And I should see the edit summary "fix typo"

  Scenario: Deleted taxon
    Given I add a taxon for the feed

    When I go to the catalog page for "Antcatinae"
    And I follow "Delete"
    And I go to the activity feed
    Then I should see "Archibald deleted the subfamily Antcatinae" and no other feed items

  Scenario: Elevated subspecies to species
    Given activity tracking is disabled
      And there is a subspecies "Solenopsis speccus subbus" which is a subspecies of "Solenopsis speccus" in the genus "Solenopsis"
    And activity tracking is enabled

    When I go to the catalog page for "Solenopsis speccus subbus"
      And I will confirm on the next step
      And I follow "Elevate to species"
    And I go to the activity feed
    Then I should see "Archibald elevated the subspecies Solenopsis speccus subbus to the rank of species (now Solenopsis subbus)" and no other feed items

  @javascript
  Scenario: Converted species to subspecies
    Given activity tracking is disabled
      And there is a species "Camponotus dallatorei" with genus "Camponotus"
      And there is a species "Camponotus alii" with genus "Camponotus"
    And activity tracking is enabled

    When I go to the catalog page for "Camponotus dallatorei"
      And I follow "Convert to subspecies"
      And I set the new species field to "Camponotus alii"
      And I wait
      And I press "Convert"
    Then I should be on the catalog page for "Camponotus alii dallatorei"

    When I go to the activity feed
    Then I should see "Archibald converted the species Camponotus dallatorei to a subspecies (now Camponotus alii dallatorei)" and no other feed items
