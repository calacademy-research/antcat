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
      And show me the page
      And I should see "Mark Wilden"

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

  Scenario: Change a reference's journal title
    Given the following entries exist in the bibliography
      |citation|
      |Esakia 31:1-115|
    When I go to the main page
      And I follow "Esakia 31:1-115"
      And I fill in "reference_citation" with "Mad Magazine 33:12"
      And I press "OK"
    Then there should be the HTML "rft.jtitle=Mad\+Magazine"
