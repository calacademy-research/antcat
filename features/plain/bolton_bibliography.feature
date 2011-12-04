Feature: View bibliography
  As an AntCat bibliography editor
  I want to see the Bolton bibliography
  So that I can compare it to AntCat's
  And so I can match it

  Scenario: View one entry
    Given the following Bolton reference exists
      |authors   |title|journal|series_volume_issue|pagination|citation_year|publisher|place   |original       |
      |Ward, P.S.|Ants |Psyche |1(2)               |3         |2011a        |Wilkins  |New York|Bolton original|
    When I go to the Bolton references page
    Then I should see "Ward, P.S."
      And I should see "Ants"
      And I should see "1(2)"
      And I should see "3"
      And I should see "2011a"
      And I should see "Bolton original"

