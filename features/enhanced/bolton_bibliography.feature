Feature: View bibliography (JavaScript)
  As an AntCat bibliography editor
  I want to see the Bolton bibliography
  So that I can compare it to AntCat's
  And so I can match it

  Scenario: Selecting a match
    Given I am logged in
    Given the following Bolton reference exists
      |authors   |title|
      |Ward, P.S.|Ants |
    And the following reference matches that Bolton reference
      |title        |similarity|
      |Ants in Pants|0.5       |
    When I go to the Bolton references page
    Then the Bolton reference should be red
      And the reference should be white
      And I should see a "Match" button
    When I press "Match"
    Then the Bolton reference should be darkgreen
      And the matched reference should be darkgreen
      And I should not see a "Match" button

  Scenario: Deselecting a match
    Given I am logged in
    Given the following Bolton reference exists
      |authors   |title|
      |Ward, P.S.|Ants |
    And the following reference matches that Bolton reference
      |title        |similarity|
      |Ants in Pants|0.8       |
    When I go to the Bolton references page
      And I press "Match"
    Then I should not see a "Match" button
      And I should see a "Unmatch" button
    When I press "Unmatch"
    Then the Bolton reference should be red
      And the reference should be white
      And I should see a "Match" button

  Scenario: Not logged in
    Given I am not logged in
    Given the following Bolton reference exists
      |authors   |title|
      |Ward, P.S.|Ants |
    And the following reference matches that Bolton reference
      |title        |similarity|
      |Ants in Pants|0.8       |
    And I go to the Bolton references page
    Then all the buttons should be disabled
