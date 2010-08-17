Feature: Copy reference
  As Phil Ward
  I want to add new references using existing reference data
  So that I can reduce copy and pasting beteen references
  And so that the bibliography continues to be up-to-date

  Scenario: Copy a reference
    Given the following entries exist in the bibliography
      |authors   |title         |
      |Ward, P.S.|Annals of Ants|
    When I go to the main page
    When I follow "copy"
      Then I should see a new edit form
    When in the new edit form I fill in "reference_authors" with "Mark Wilden"
      And in the new edit form I press "OK"
    Then I should see "Mark Wilden . Annals of Ants"
