Feature: Copy reference
  As Phil Ward
  I want to add new references using existing reference data
  So that I can reduce copy and pasting beteen references
  And so that the bibliography continues to be up-to-date

  Scenario: Not logged in
    Given I am not logged in
      And the following entries exist in the bibliography
      |authors   |title         |citation|year|
      |Ward, P.S.|Annals of Ants|Ants 1:2|1910|
    When I go to the main page
    Then "copy" should not be visible

  Scenario: Copy a reference
    Given I am logged in
      And the following entries exist in the bibliography
      |authors   |title         |citation|year|
      |Ward, P.S.|Annals of Ants|Ants 1:2|1910|
    When I go to the main page
    When I follow "copy"
      Then I should see a new edit form
    When in the new edit form I fill in "reference_title" with "Tapinoma"
      And in the new edit form I press the "Save" button
    Then I should see "1910. Tapinoma."
