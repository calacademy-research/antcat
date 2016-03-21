@feed
Feature: Feed
  As an AntCat editor
  I want to see what has changed in the database

  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: No activities
    When I go to the activity feed
    Then I should see "No activities"

  Scenario: Added journal
    When I add a journal for the feed
    And I go to the activity feed
    Then I should see "Archibald added the journal Archibald Bulletin"

  Scenario: Edited journal
    When I edit a journal for the feed
    And I go to the activity feed
    Then I should see "Archibald edited the journal New Journal Name"

  Scenario: Deleted journal
    When I delete a journal for the feed
    And I go to the activity feed
    Then I should see "Archibald deleted the journal Archibald Bulletin"

  Scenario: Approve all references
    Given I log in as a superadmin named "Archibald"

    When I create a bunch of references for the feed
    And I go to the references page
    And I follow "Latest Changes"
    And I press "Approve all"
    And I go to the activity feed
    Then I should see "Archibald approved all unreviewed references (2 in total)."
