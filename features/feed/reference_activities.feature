@feed
Feature: Feed (references)
  Background:
    Given I log in as a catalog editor named "Archibald"

  @javascript
  Scenario: Added reference (with edit summary)
    When I go to the references page
      And I follow "New"
      And I fill in "reference_author_names_string" with "Ward, B.L.; Bolton, B."
      And I fill in "reference_title" with "A reference title"
      And I fill in "reference_citation_year" with "1981"
      And I follow "Other"
      And I fill in "reference_citation" with "Required"
      And I fill in "edit_summary" with "for Lasius niger"
      And I press "Save"
    And I go to the activity feed
    Then I should see "Archibald added the reference Ward & Bolton, 1981" and no other feed items
    And I should see the edit summary "for Lasius niger"

  Scenario: Edited reference (with edit summary)
    Given there is a reference for the feed with state "reviewed"

    When I go to the edit page for the most recent reference
      And I fill in "reference_title" with "A reference title"
      And I fill in "edit_summary" with "fix typo"
      And I press "Save"
    And I go to the activity feed
    Then I should see "Archibald edited the reference Giovanni, 1809" and no other feed items
    And I should see the edit summary "fix typo"

  Scenario: Started reviewing reference
    Given there is a reference for the feed with state "none"

    When I go to the latest reference additions page
      And I follow "Start reviewing"
    And I go to the activity feed
    Then I should see "Archibald started reviewing the reference Giovanni, 1809" and no other feed items

  Scenario: Finished reviewing reference
    Given there is a reference for the feed with state "reviewing"

    When I go to the latest reference additions page
      And I follow "Finish reviewing"
    And I go to the activity feed
    Then I should see "Archibald finished reviewing the reference Giovanni, 1809" and no other feed items

  Scenario: Restarted reviewing reference
    Given there is a reference for the feed with state "reviewed"

    When I go to the latest reference additions page
      And I follow "Restart reviewing"
    And I go to the activity feed
    Then I should see "Archibald restarted reviewing the reference Giovanni, 1809" and no other feed items

  Scenario: Approved all references
    Given I log in as a superadmin named "Archibald"
    And there is a reference for the feed with state "none"

    When I go to the references page
    And I follow "Latest Changes"
    And I follow "Approve all"
    And I go to the activity feed
    Then I should see "Archibald approved all unreviewed references (1 in total)."
    And I should see 2 items in the feed
