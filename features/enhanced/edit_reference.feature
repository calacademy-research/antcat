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
    When I follow "Authors 2010. Title Citation"
      Then I should see an edit form
      And I should not see a reference
    When I fill in "reference_authors" with "Mark Wilden"
      And I press "OK"
    Then I should be on the main page
      And I should not see an edit form
      And I should see "Mark Wilden"
      And I should see "This reference has been updated"

  Scenario: Change a reference's year
    Given the following entries exist in the bibliography
      |authors|title|citation|year|
      |Fisher |Ants |New York|2010|
    When I go to the main page
      And I follow "Fisher 2010. Ants New York"
      And I fill in "reference_year" with "1910a"
      And I press "OK"
      And I fill in "start_year" with "1910"
      And I press "Search"
    Then I should see "Fisher 1910a"

