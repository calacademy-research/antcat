@javascript
Feature: Taxon Browser Panels
  As a user of AntCat
  I want be able to open and close the taxon browser panels
  So that I can choose a taxon easily

  Background:
    Given the Formicidae family exists
    And there is a subfamily "Myrmicinae"
    And a genus exists with a name of "Atta" and a subfamily of "Myrmicinae"
    And a species exists with a name of "abruptus" and a genus of "Atta"

  @taxon_browser
  Scenario: Opening and closing panels
    When I go to the catalog page for "Atta"
    And I click the taxon browser toggler
    Then I should see the family panel closed
    And I should see the subfamily panel closed
    And I should see the genus panel opened

    When I click on the subfamily panel
    Then I should see the family panel closed
    And I should see the subfamily panel opened
    And I should see the genus panel opened

  @taxon_browser
  Scenario: Close all except last panel by default
    When I go to the catalog page for "Atta"
    And I click the taxon browser toggler
    Then I should see the family panel closed
    And I should see the subfamily panel closed
    And I should see the genus panel opened

  Scenario: All panels open by default in test env
    When I go to the catalog page for "Atta"
    Then I should see all taxon browser panels opened

  @taxon_browser
  Scenario: All panels open if asked to
    When I go to the catalog page for "Atta"
    And I click the taxon browser toggler
    Then I should see the family panel closed
    And I should see the subfamily panel closed
    And I should see the genus panel opened

    When I uncheck "close_inactive_panels"
    And I reload the page
    And I click the taxon browser toggler
    Then I should see all taxon browser panels opened
