@javascript
Feature: Reference picker

  Background:
    Given the following references exist
      | authors        | year          | title                 | citation   |
      | Fisher, B.     | 1995b         | Anthill               | Ants 1:1-2 |
      | Hölldobler, B. | 1995b         | Formis                | Ants 1:1-2 |
      | Bolton, B.     | 2010 ("2011") | Ants of North America | Ants 2:1-2 |

  Scenario: Seeing the picker
    When I go to the reference picker widget test page
    Then I should see "Fisher, B. 1995b. Anthill. Ants 1:1-2."

  Scenario: Searching
    When I go to the reference picker widget test page
    * I fill in the search box with "Bolton"
    * I press "Go" by the search box
    Then I should see "Bolton, B."
    * I should not see "Fisher, B."
    * I should not see "Hölldobler, B."

