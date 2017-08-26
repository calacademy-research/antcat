@feed
Feature: Feed (merge authors)
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Merging
    Given activity tracking is disabled
      And the following names exist for an author
        | Bolton, B. |
      And the following names exist for another author
      | Fisher, B. |
    And activity tracking is enabled

    When I go to the merge authors page
      And I search for "Bolton, B." in the author panel
      And I search for "Fisher, B." in another author panel
      And I merge the authors
    And I go to the activity feed
    Then I should see "Archibald merged the author(s) Fisher, B. into author #" and no other feed items
