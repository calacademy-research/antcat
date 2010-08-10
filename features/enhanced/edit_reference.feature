Feature: Edit reference
  As Phil Ward
  I want to change previously entered references
  So that I can fix mistakes

  Scenario: Edit a reference
    Given the following entries exist in the bibliography
      |authors|citation|cite_code|created_at|date    |possess|title|updated_at|year|
      |Authors|Citation|CiteCode |today     |20100712|Possess|Title|today     |2010|
    When I go to the main page
      Then I should not see an edit form
      When I follow "Edit"
      Then I should see an edit form
      And I should not see a reference
    When I fill in "reference_authors" with "Mark Wilden"
      And I press "OK"
    Then I should be on the main page
      And I should not see an edit form
      And I should see "Mark Wilden"
      And I should see "Reference has been updated"
