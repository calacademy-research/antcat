Feature: View bibliography
  As an AntCat bibliography editor
  I want to see the Bolton bibliography
  So that I can compare it to AntCat's
  And so I can match it

  Scenario: View one entry
    Given the following Bolton reference exists
      |authors   |
      |Ward, P.S.|
    When I go to the Bolton references page
    Then I should see "Ward, P.S."
