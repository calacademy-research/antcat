Feature: Searching references
  @search
  Scenario: Searching for an author name with diacritics, using the diacritics in the query
    Given these references exist
      | author         | title             |
      | Hölldobler, B. | Hölldobler's Ants |
      | Fisher, B.     | Fisher's Ants     |
    And I go to the references page

    When I fill in "reference_q" with "Hölldobler" within the desktop menu
    And I click on the reference search button
    Then I should see "Hölldobler, B."
    And I should not see "Fisher, B."

  Scenario: Finding nothing
    Given I go to the references page

    When I fill in "reference_q" with "zzzzzz" within the desktop menu
    And I click on the reference search button
    And I should see "No results found"

  Scenario: Maintaining search box contents
    Given I go to the references page

    When I fill in "reference_q" with "zzzzzz year:1972-1980" within the desktop menu
    And I click on the reference search button
    Then I should see "No results found"
    And the "reference_q" field within "#desktop-menu" should contain "zzzzzz year:1972-1980"
