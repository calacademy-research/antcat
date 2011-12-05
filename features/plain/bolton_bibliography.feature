Feature: View bibliography
  As an AntCat bibliography editor
  I want to see the Bolton bibliography
  So that I can compare it to AntCat's
  And so I can match it

  Scenario: Go to Bolton references and view one entry
    Given the following Bolton reference exists
      |authors   |title|journal|series_volume_issue|pagination|citation_year|publisher|place   |original       |
      |Ward, P.S.|Ants |Psyche |1(2)               |3         |2011a        |Wilkins  |New York|Bolton original|
    When I go to the main page
      And I follow "Bolton References"
    Then I should see "Ward, P.S."
      And I should see "Ants"
      And I should see "1(2)"
      And I should see "3"
      And I should see "2011a"
      And I should see "Bolton original"

  Scenario: Search
    Given the following Bolton references exist
      |authors   |title|journal|series_volume_issue|pagination|citation_year|publisher|place   |original       |
      |Ward, P.S.|Ants |Psyche |1(2)               |3         |2011a        |Wilkins  |New York|Ward original  |
      |Fisher, B.|Atta |Science |4(5)              |7         |2012a        |Barry    |London  |Fisher original|
    When I go to the Bolton references page
    Then I should see "Ward, P.S."
      And I should see "Ants"
      And I should see "1(2)"
      And I should see "3"
      And I should see "2011a"
      And I should see "Ward original"
    And I should see "Fisher, B."
      And I should see "Atta"
      And I should see "4(5)"
      And I should see "3"
      And I should see "2011a"
      And I should see "Ward original"
    When I fill in the search box with "Fisher"
      And I press "Go" by the search box
    Then I should see "Fisher, B."
      And I should not see "Ward"

