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

  Scenario: Seeing matches
    Given the following Bolton reference exists
      |authors   |title|journal|series_volume_issue|pagination|citation_year|publisher|place   |original       |
      |Ward, P.S.|Ants |Psyche |1(2)               |3         |2011a        |Wilkins  |New York|Bolton original|
      And the following references match that Bolton reference
        |title        |similarity|
        |Ants in Pants|0.8       |
        |Antses       |0.8       |
    When I go to the Bolton references page
    Then I should see "Antses"
      And I should see "Ants in Pants"
      And I should see "0.8"

  Scenario: Seeing just references for which the best match is below a threshold
    Given the following Bolton reference exists
      |authors   |title|
      |Ward, P.S.|Ants |
    And the following reference matches that Bolton reference
      |title        |similarity|
      |Ants in Pants|0.5       |
    And the following Bolton reference exists
      |authors   |title       |
      |Bolton, B.|Leafcutters |
    And the following reference matches that Bolton reference
      |title      |similarity|
      |Leafcutters|1         |
    When I go to the Bolton references page
    Then I should see "Ants in Pants"
      And I should see "Leafcutters"
    When I fill in the match threshold with ".6"
      And I press "Go" by the search box
    Then I should see "Ants in Pants"
      And I should not see "Leafcutters"

  Scenario: Seeing just references with a given match type
    Given the following Bolton reference exists
      |authors   |title|match_type|
      |Ward, P.S.|Ants |auto      |
      |Fisher, B.|Ant  |          |
    When I go to the Bolton references page
    Then the "Auto" checkbox should be checked
      And the "None" checkbox should be checked
      And I should see "Ward"
      And I should see "Fisher"
    When I uncheck "Auto"
      And I press "Go" by the search box
    Then I should not see "Ward"
      And I should see "Fisher"
    When I uncheck "None"
      And I press "Go" by the search box
    Then I should see "Ward"
      And I should see "Fisher"

  Scenario: Selecting a match
    Given the following Bolton reference exists
      |authors   |title|
      |Ward, P.S.|Ants |
    And the following reference matches that Bolton reference
      |title        |similarity|
      |Ants in Pants|0.5       |
    When I go to the Bolton references page
    Then the Bolton reference should be red
      And the reference should be white
    When I press "Match"
    Then the Bolton reference should be green
      And the matched reference should be green
