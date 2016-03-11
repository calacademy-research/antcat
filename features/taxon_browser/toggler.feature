@javascript
Feature: Taxon Browser Toggler
  As a user of AntCat
  I want be able to show and hide the taxon browser
  So that I can choose a taxon easily

  Background:
    Given the Formicidae family exists

  @taxon_browser
  Scenario: Open by default
    When I go to the catalog
    Then I should see the taxon browser

  @taxon_browser
  Scenario: Toggle show/hide (desktop menu)
    When I go to the catalog
    Then I should see the taxon browser

    When I click the taxon browser toggler
    Then I should not see the taxon browser

  @responsive @taxon_browser
  Scenario: Toggle show/hide (mobile menu)
    When I go to the catalog
    Then I should see the desktop layout
    And I should see the taxon browser

    When I resize the browser window to mobile
    Then I should see the mobile layout
    And I should see the taxon browser

    When I click the mobile taxon browser toggler
    Then I should not see the taxon browser

  @taxon_browser
  Scenario: Remembering open/closed state
    When I go to the catalog
    Then I should see the taxon browser

    When I check "keep_taxon_browser_open"
    And I click the taxon browser toggler
    Then I should not see the taxon browser

    When I reload the page
    Then I should not see the taxon browser

  @taxon_browser
  Scenario: Keep open checkbox
    # visible + on = SHOW
    When I go to the catalog
    Then "keep_taxon_browser_open" should be checked
    Then I should see the taxon browser

    # hidden + off = HIDE
    # hides visible browser unless asked not to
    When I uncheck "keep_taxon_browser_open"
    And I click the taxon browser toggler
    Then I should not see the taxon browser
    When I reload the page
    Then I should not see the taxon browser

    # visible + off = HIDE
    # only show browser if it's open and asked to not hide it
    When I click the taxon browser toggler
    And I reload the page
    Then I should not see the taxon browser

    # hidden + on = HIDE
    # if browser is hidden, keep it hidden even if "keep open" is checked
    When I click the taxon browser toggler
    And I check "keep_taxon_browser_open"
    And I click the taxon browser toggler
    And I reload the page
    Then I should not see the taxon browser
