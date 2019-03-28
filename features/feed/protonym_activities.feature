@feed
Feature: Feed (protonyms)
  Background:
    Given I log in as a catalog editor named "Archibald"

  Scenario: Edited a protonym
    Given there is a genus protonym "Formica" with pages and form 'page 9, dealate queen'

    When I go to the protonyms page
    And I follow "Formica"
    And I follow "Edit"
    And I fill in "protonym_authorship_attributes_pages" with "page 35"
    And I fill in "edit_summary" with "fix typo"
    And I press "Save"
    And I go to the activity feed
    Then I should see "Archibald edited the protonym Formica" and no other feed items
    And I should see the edit summary "fix typo"

  Scenario: Deleted a protonym
    Given there is a genus protonym "Formica" with pages and form 'page 9, dealate queen'

    When I go to the protonyms page
    And I follow "Formica"
    And I follow "Delete"
    And I go to the activity feed
    Then I should see "Archibald deleted the protonym Formica" and no other feed items
