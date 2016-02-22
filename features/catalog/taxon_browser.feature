@javascript
Feature: Taxon browser
  As a user of AntCat
  I want be able to show and hide the taxon browser
  So that I can choose a taxon easily

  Background:
    Given the Formicidae family exists

  Scenario: Show/hide
    When I go to the catalog
    Then I should see the taxon browser
    Then I toggle the taxon browser
    And I screenshot
    Then I should not see the taxon browser
    And I screenshot
