Feature: View reference when logged in and logged out
  As a user
  I want to see the bibliography
  But Phil doesn't want me to see certain notes unless I'm logged in

  Background:
    Given the following entries exist in the bibliography
      |authors|citation  |cite_code|created_at|date    |possess|title|updated_at|year|notes           |taxonomic_notes|
      |authors|Psyche 3:3|CiteCode |today     |20100712|Possess|title|today     |2010|{Public} Editor |Taxonomy      |

  Scenario: Not logged in
    Given I am not logged in
    When I go to the main page
    Then I should see "Public"
      And I should not see "Editor"
      And I should not see "Taxonomy"

  Scenario: Logged in
    When I log in
      And I go to the main page
    Then I should see "Public"
      And I should see "Editor"
      And I should see "Taxonomy"
