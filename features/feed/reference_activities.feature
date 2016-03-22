@feed
Feature: Feed (references)
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Approved all references
    Given I log in as a superadmin named "Archibald"

    When I create a bunch of references for the feed
    And I go to the references page
    And I follow "Latest Changes"
    And I press "Approve all"
    And I go to the activity feed
    Then I should see "Archibald approved all unreviewed references (2 in total)."
