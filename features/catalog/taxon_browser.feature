@javascript
Feature: Taxon browser
  As a user of AntCat
  I want be able to show and hide the taxon browser
  So that I can choose a taxon easily

  Background:
    Given the Formicidae family exists

  Scenario: Show/hide (desktop menu)
    When I go to the catalog
    Then I should see the taxon browser
    Then I toggle the taxon browser
    Then I should not see the taxon browser

  Scenario: Show/hide (mobile menu)
    When I go to the catalog
    Then I should see the taxon browser

    When I resize the browser window to mobile
    Then I should see the desktop site
    And I should see the taxon browser

    And I toggle the taxon browser
    Then I should not see the taxon browser
