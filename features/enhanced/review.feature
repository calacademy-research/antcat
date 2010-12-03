Feature: Reviewing features
  As an editor of AntCat
  I want to see recently changed references
  So that I can review, fix and monitor them

  Scenario: Not logged in
    When I go to the main page
    Then I should not see "Review"

  Scenario: Logged in
    Given I am logged in
    And the following entries exist in the bibliography
      |authors   |citation  |created_at|title            |updated_at|year|
      |Ward, P.  |Psyche 5:3|today     |Ward's World     |2010-2-2  |2010|
      |Bolton, B.|Psyche 4:2|yesterday |Bolton's Bulletin|2010-1-1  |2010|
    When I go to the main page
      And I press the "Review" button
    Then I should see these entries in this order:
      |entry|
      |Ward, P. 2010. Ward's World. Psyche 5:3.|
      |Bolton, B. 2010. Bolton's Bulletin. Psyche 4:2.|
