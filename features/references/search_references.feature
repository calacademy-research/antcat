Feature: Searching references
  Background:
    Given these references exist
      | author         | title             |
      | Hölldobler, B. | Hölldobler's Ants |
      | Fisher, B.     | Fisher's Ants     |
    And I go to the references page

  @search
  Scenario: Searching for an author name with diacritics, using the diacritics in the query
    When I fill in "reference_q" with "Hölldobler" within the desktop menu
    And I press "Go" by the references search box
    Then I should see "Hölldobler, B."
    Then I should not see "Fisher, B."

  Scenario: Finding nothing
    When I fill in "reference_q" with "zzzzzz" within the desktop menu
    And I press "Go" by the references search box
    And I should see "No results found"

  Scenario: Maintaining search box contents
    When I fill in "reference_q" with "zzzzzz year:1972-1980" within the desktop menu
    And I press "Go" by the references search box
    Then I should see "No results found"
    And the "reference_q" field within "#desktop-menu" should contain "zzzzzz year:1972-1980"

  @javascript @search
  Scenario: Search using autocomplete
    When I fill in "reference_q" with "hol" within the desktop menu
    Then I should see the following autocomplete suggestions:
      | Hölldobler's Ants |
    And I should not see the following autocomplete suggestions:
      | Fisher's Ants |

  @javascript @search
  Scenario: Search using autocomplete keywords
    When I fill in "reference_q" with "author:fish" within the desktop menu
    Then I should see the following autocomplete suggestions:
      | Fisher's Ants |
    And I should not see the following autocomplete suggestions:
      | Hölldobler's Ants |

    When I click the first autocomplete suggestion
    Then the search box should contain "author:'Fisher, B.'"

  @search
  Scenario: Searching for one author only (keyword search)
    Given a Hölldobler-Fisher reference exists with the title "Hölldobler and Fisher's Favorite Ants"

    When I fill in "reference_q" with "author:'Fisher, B.'" within the desktop menu
    And I press "Go" by the references search box
    Then I should see "Hölldobler and Fisher's Favorite Ants"
    And I should not see "Hölldobler's Ants"
    And I should see "Fisher's Ants"
