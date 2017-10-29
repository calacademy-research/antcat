@feed
Feature: Feed (tooltips)
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Added tooltip
    When I go to the tooltips editing page
      And I follow "New Tooltip"
      And I fill in "tooltip[key]" with "authors"
      And I fill in "tooltip[scope]" with "taxa"
      And I fill in "tooltip[text]" with "Text used in the tooltip"
      And I press "Create Tooltip"

    And I go to the activity feed
    Then I should see "Archibald added the tooltip taxa.authors" and no other feed items

  Scenario: Edited tooltip
    Given there is a tooltip for the feed

    When I go to the tooltips editing page
      And I follow "authors"
      And I fill in "tooltip[text]" with "Swooooosh"
      And I press "Update Tooltip"
    And I go to the activity feed
    Then I should see "Archibald edited the tooltip taxa.authors" and no other feed items

  Scenario: Deleted tooltip
    Given there is a tooltip for the feed

    When I go to the tooltips editing page
      And I follow "authors"
      And I follow "Delete"
    And I go to the activity feed
    Then I should see "Archibald deleted the tooltip taxa.authors" and no other feed items