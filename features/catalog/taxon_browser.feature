@javascript
Feature: Taxon browser
  As a user of AntCat
  I want be able to show and hide the taxon browser
  So that I can choose a taxon easily

  Background:
    Given the Formicidae family exists

  @taxon_browser
  Scenario: Closed by default
    When I go to the catalog
    Then I should not see the taxon browser

  @taxon_browser
  Scenario: Toggle show/hide (desktop menu)
    When I go to the catalog
    Then I should not see the taxon browser

    When I click the taxon browser toggler
    Then I should see the taxon browser

  @responsive @taxon_browser
  Scenario: Toggle show/hide (mobile menu)
    When I go to the catalog
    Then I should see the desktop layout
    And I should not see the taxon browser

    When I resize the browser window to mobile
    Then I should see the mobile layout
    And I should not see the taxon browser

    When I click the mobile taxon browser toggler
    Then I should see the taxon browser

  @taxon_browser
  Scenario: Remembering open/closed state
    When I go to the catalog
    Then I should not see the taxon browser

    When I click the taxon browser toggler
    Then I should see the taxon browser

    When I reload the page
    Then I should see the taxon browser

  @taxon_browser
  Scenario: Opening and closing panels
    Given there is a subfamily "Myrmicinae"
    And a genus exists with a name of "Atta" and a subfamily of "Myrmicinae"
    And a species exists with a name of "abruptus" and a genus of "Atta"

    When I go to the catalog page for "Atta"
    And I click the desktop taxon browser toggler
    Then I should see the subfamilies panel closed
    And I should see the genera panel closed
    And I should see the species panel opened

    When I click on the subfamilies panel
    Then I should see the subfamilies panel opened
    And I should see the genera panel closed
    And I should see the species panel opened

  @taxon_browser
  Scenario: Close all except last panel by default
    Given there is a subfamily "Myrmicinae"
    And a genus exists with a name of "Atta" and a subfamily of "Myrmicinae"
    And a species exists with a name of "abruptus" and a genus of "Atta"

    When I go to the catalog page for "Atta"
    And I click the desktop taxon browser toggler
    Then I should see the subfamilies panel closed
    And I should see the genera panel closed
    And I should see the species panel opened

  Scenario: All panels open by default in test env
    Given there is a subfamily "Myrmicinae"
    And a genus exists with a name of "Atta" and a subfamily of "Myrmicinae"
    And a species exists with a name of "abruptus" and a genus of "Atta"

    When I go to the catalog page for "Atta"
    Then I should see all taxon browser panels opened
    And I screenshot
