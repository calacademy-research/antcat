Feature: Replace missing references

  Scenario: Not logged in
    Given there is a missing reference with citation "Bolton, 1970" in a protonym
    When I go to the missing references page
    Then I should see "Bolton, 1970"
    And I should not see "edit" in the first row of missing references

  Scenario: Seeing all the authors with their names
    Given there is a missing reference with citation "Bolton, 1970" in a protonym
    And there is a missing reference with citation "Fisher, 1990" in a protonym
    Given I am logged in
    When I go to the missing references page
    Then I should see "Bolton, 1970"
    And I should see "Fisher, 1990"

  @javascript
  @search
  Scenario: Replacing a missing reference
    Given I am logged in
    And this reference exists
      | authors | citation   | title | year | doi |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |          |
    And there is a missing reference with citation "Bolton, 1970" in a protonym
    When I go to the missing references page
    Then I should see "Bolton, 1970"
    When I click "replace" in the first row of missing references
    Then I should be on the missing reference edit page for "Bolton, 1970"
    When I click the replacement field
    And in the reference picker, I search for the author "Fisher"
    And I click the first search result
    And I press "OK"
    Given I will confirm on the next step
    When I press "OK"
    Then I should be on the missing references page
    And I should not see "Bolton, 1970"

  #Scenario: Attempting to access edit page without being logged in
    #Given the following names exist for an author
      #| Bolton, B. |
    #When I go to the author edit page for "Bolton, B."
    #Then I should be on the login page

  #Scenario: Going back to authors page from author page
    #Given the following names exist for an author
      #| Bolton, B. |
    #And I am logged in
    #When I go to the author edit page for "Bolton, B."
    #And I follow "Back to Authors"
    #Then I should be on the authors page
