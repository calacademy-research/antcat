Feature: Reviewing features
  As an editor of AntCat
  I want to see recently changed references
  So that I can review, fix and monitor them

  Scenario: Not logged in
    When I go to the main page
    Then I should not see "Review"

  Scenario: Logged in
    When I log in
      And I go to the main page
    Then I should see "Show latest changes"

  Scenario: See features in reverse chronological order
      And the following references exist
      |authors   |citation  |created_at|title            |updated_at|year|
      |Ward, P.  |Psyche 5:3|today     |Ward's World     |2010-2-2  |2010|
      |Bolton, B.|Psyche 4:2|yesterday |Bolton's Bulletin|2010-1-1  |2010|
    Given I am logged in
    When I go to the main page
      And I follow "Show latest changes"
    Then I should see these entries with a header in this order:
      |updated_at|entry|
      |2010-02-02|Ward, P. 2010. Ward's World. Psyche 5:3.|
      |2010-01-01|Bolton, B. 2010. Bolton's Bulletin. Psyche 4:2.|
