@javascript
Feature: Reference picker

  Background:
    Given the following references exist
      | authors                 | year          | title                 | citation   |
      | Fisher, B.              | 1995b         | Fisher's book         | Ants 1:1-2 |
      | Bolton, B.              | 2010 ("2011") | Bolton's book         | Ants 2:1-2 |
      | Fisher, B.; Bolton, B.  | 1995b         | Fisher Bolton book    | Ants 1:1-2 |
      | Hölldobler, B.          | 1995b         | Bert's book           | Ants 1:1-2 |

  Scenario: Seeing the picker
    When I visit the reference picker widget test page, opened to the first reference
    Then I should see "Fisher, B. 1995b. Fisher's book. Ants 1:1-2."

  Scenario: Searching
    When I go to the reference picker widget test page
    And I search for "Bolton"
    Then I should see "Bolton's book"
    * I should see "Fisher Bolton book"
    * I should not see "Bert's book"
    * I should not see "Fisher's book"

  Scenario: Searching for multiple authors
    When I go to the reference picker widget test page
    And I search for the authors "Bolton, B.;Fisher, B."
    Then I should see "Fisher Bolton book"
    And I should not see "Fisher's book"
    And I should not see "Bolton's book"

  Scenario: Editing the selected reference
    Given I am logged in
    When I visit the reference picker widget test page, opened to the first reference
    And I edit the reference
    When I set the authors to "Ward, B.L.; Bolton, B."
    And I set the title to "Ant Title"
    And I save the form
    Then I should see "Ward, B.L.; Bolton, B. 1995b. Ant Title"
