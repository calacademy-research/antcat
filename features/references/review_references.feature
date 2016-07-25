Feature: Reviewing features
  As an editor of AntCat
  I want to see recently changed references
  So that I can review, fix and monitor them

  Scenario: Not logged in
    When I go to the references page
    Then I should not see "Latest Changes"

  Scenario: Logged in
    When I log in
    And I go to the references page
    Then I should see "Latest Changes"

  Scenario: See features in reverse chronological order
    Given these references exist
      | authors    | citation   | title             | created_at | updated_at | year |
      | Ward, P.   | Psyche 5:3 | Ward's World      | 2010-2-2   | 2012-2-2   | 2010 |
      | Bolton, B. | Psyche 4:2 | Bolton's Bulletin | 2010-1-1   | 2012-1-1   | 2010 |
    And I am logged in

    When I go to the references page
    And I follow "Latest Changes"
    Then I should see these entries with a header in this order:
      | updated_at | entry                                          |
      | 2012-02-02 | Ward, P. 2010. Ward's World. Psyche 5:3        |
      | 2012-01-01 | Bolton, B. 2010. Bolton's Bulletin. Psyche 4:2 |
