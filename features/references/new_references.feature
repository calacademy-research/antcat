Feature: Seeing what's new
  As a user of AntCat
  I want to see recently added references
  So I can keep up with the state of the literature

  Scenario: See features in order of addition
    Given these references exist
      | authors    | citation   | created_at | title             | created_at | updated_at | year | status    |
      | Ward, P.   | Psyche 5:3 | today      | Ward's World      | 2010-2-2   | 2010-1-1   | 2010 | None      |
      | Bolton, B. | Psyche 4:2 | yesterday  | Bolton's Bulletin | 2010-1-1   | 2010-2-2   | 2010 | Reviewing |
    When I go to the references page
    And I follow "Latest additions"
    Then I should see these entries with a header in this order:
      | date       | entry                                           | status   |
      | 2010-02-02 | Ward, P. 2010. Ward's World. Psyche 5:3.        | None     |
      | 2010-01-01 | Bolton, B. 2010. Bolton's Bulletin. Psyche 4:2. | Reviewing|

