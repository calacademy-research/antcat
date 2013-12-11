@dormant
Feature: Searching references
  As a user of AntCat
  I want to search for references
  So that I can use one in my paper
    Or see if I have already added it

  Background:
    Given these references exist
      | authors        | year          | title                 | citation   |
      | Fisher, B.     | 1995b         | Anthill               | Ants 1:1-2 |
      | Hölldobler, B. | 1995b         | Formis                | Ants 1:1-2 |
      | Bolton, B.     | 2010 ("2011") | Ants of North America | Ants 2:1-2 |

  Scenario: Not searching yet
    When I go to the references page
    Then I should see "Fisher, B."
    And I should see "Hölldobler, B."
    And I should see "Bolton, B."

  Scenario: Finding nothing
    When I go to the references page
    And I fill in the search box with "zzzzzz"
    And I press "Go" by the search box
    Then I should not see "Fisher, B."
    And I should not see "Bolton, B."
    And I should not see "Hölldobler, B."
    And I should see "No results found"

  Scenario: Maintaining search box contents
    When I go to the references page
    And I fill in the search box with "zzzzzz 1972-1980"
    And I press "Go" by the search box
    Then I should see "No results found"
    And the "q" field should contain "zzzzzz 1972-1980"

  Scenario: Searching by ID
    Given there is a reference with ID 50000 for Dolerichoderinae
    When I go to the references page
    And I fill in the search box with "50000"
    And I press "Go" by the search box
    Then I should see "Dolerichoderinae"
    When I fill in the search box with "10000"
    And I press "Go" by the search box
    Then I should not see "Dolerichoderinae"
