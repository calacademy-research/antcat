@javascript
Feature: Adding a taxon
  As an editor of AntCat
  I want to add taxa
  So that information is kept up-to-date
  So people use AntCat

  Scenario: Adding a genus
    Given there is a subfamily "Formicinae"
    And I log in
    When I go to the edit page for "Formicinae"
    And I press "Add Genus"
    Then I should be on the new genus edit page
