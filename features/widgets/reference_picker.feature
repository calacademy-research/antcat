@javascript
Feature: Reference picker

  Scenario: Seeing the picker
    Given the following references exist
      | authors        | year          | title                 | citation   |
      | Fisher, B.     | 1995b         | Anthill               | Ants 1:1-2 |
      | Hölldobler, B. | 1995b         | Formis                | Ants 1:1-2 |
      | Bolton, B.     | 2010 ("2011") | Ants of North America | Ants 2:1-2 |
    When I go to the reference picker widget test page
    Then I should see "Fisher, B. 1995b. Anthill. Ants 1:1-2."
