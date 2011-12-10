Feature: View bibliography (JavaScript)
  As an AntCat bibliography editor
  I want to see the Bolton bibliography
  So that I can compare it to AntCat's
  And so I can match it

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
    Then the Bolton reference should be darkgreen
      And the matched reference should be darkgreen
