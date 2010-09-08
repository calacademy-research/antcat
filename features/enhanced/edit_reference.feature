Feature: Edit reference
  As Phil Ward
  I want to change previously entered references
  So that I can fix mistakes

  Scenario: Not logged in
    Given I am not logged in
      And the following entries exist in the bibliography
      |authors|citation|cite_code|created_at|date    |possess|title|updated_at|year|
      |authors|Psyche 3:3|CiteCode |today     |20100712|Possess|title|today     |2010|
    When I go to the main page
      And I click the reference
      Then there should not be an edit form

  Scenario: Edit a reference
    Given I am logged in
      And the following entries exist in the bibliography
      |authors|citation|cite_code|created_at|date    |possess|title|updated_at|year|
      |authors|Psyche 5:3|CiteCode |today     |20100712|Possess|title|today     |2010|
    When I go to the main page
      Then I should not see the edit form
    When I click the reference
      Then I should see the edit form
      And I should not see the reference
    When I fill in "ward_reference_authors" with "Mark Wilden"
      And I press "OK"
    Then I should be on the main page
      And I should not see the edit form
      And I should see "Mark Wilden"

  Scenario: Change a reference's year
    Given I am logged in
      And the following entries exist in the bibliography
      |authors|title|citation|year|
      |Fisher |Ants |Psyche 6:4|2010|
    When I go to the main page
      And I click the reference
      And I fill in "ward_reference_year" with "1910a"
      And I press "OK"
      And I fill in "start_year" with "1910"
      And I press "Search"
    Then I should see "Fisher 1910a"

  Scenario: Change a reference's journal title
    Given I am logged in
      And the following entries exist in the bibliography
      |citation|authors|title|year|
      |Esakia 31:1-115|authors|title|year|
    When I go to the main page
      And I click the reference
      And I fill in "ward_reference_citation" with "Mad Magazine 33:12"
      And I press "OK"
    Then there should be the HTML "rft.jtitle=Mad\+Magazine"
