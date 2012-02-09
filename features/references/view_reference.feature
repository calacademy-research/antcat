@dormant
Feature: View reference when logged in and logged out
  As a user
  I want to see the bibliography
  But Phil doesn't want me to see certain notes unless I'm logged in

  Background:
      And the following references exist
      |authors|citation  |title|year|public_notes|editor_notes|taxonomic_notes|
      |authors|Psyche 3:3|title|2010|Public      |Editor      |Taxonomy       |

  Scenario: Not logged in
    Given I am not logged in
    When I go to the references page
    Then I should see "Public"
      And I should not see "Editor"
      And I should not see "Taxonomy"

  Scenario: Logged in
    When I log in
      And I go to the references page
    Then I should see "Public"
      And I should see "Editor"
      And I should see "Taxonomy"
