@feed
Feature: Feed (missing references)
  Background:
    Given I log in as a catalog editor named "Archibald"

  @search @javascript
  Scenario: Replacing a missing reference
    Given activity tracking is disabled
      And this reference exists
        | authors | citation   | title | year |
        | Fisher  | Psyche 3:3 | Ants  | 2004 |
      And there is a missing reference with citation "Bolton, 1970" in a protonym
    And activity tracking is enabled

    When I go to the missing references page
      And I follow "replace"
      And I click the replacement field
      And in the reference picker, I search for the author "Fisher"
      And I click the first search result
      And I press "OK"
      And I will confirm on the next step
      And I press "Replace"
    And I go to the activity feed
    Then I should see "Archibald replaced the missing reference Bolton, 1970 (reason missing: unknown) with Fisher, 2004" and no other feed items
