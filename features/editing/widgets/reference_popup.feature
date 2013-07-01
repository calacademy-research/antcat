@javascript
Feature: Reference popup

  Background:
    Given these references exist
      | authors                 | year          | title                 | citation   |
      | Fisher, B.              | 1995b         | Fisher's book         | Ants 1:1-2 |
      | Bolton, B.              | 2010 ("2011") | Bolton's book         | Ants 2:1-2 |
      | Fisher, B.; Bolton, B.  | 1995b         | Fisher Bolton book    | Ants 1:1-2 |
      | Hölldobler, B.          | 1995b         | Bert's book           | Ants 1:1-2 |

  Scenario: Seeing the popup
    When I go to the reference popup widget test page, opened to the first reference
    Then the current reference should be "Fisher, B. 1995b. Fisher's book. Ants 1:1-2."

  Scenario: Selecting a reference from search results
    Given I am logged in
    When I go to the reference popup widget test page
    And I search for the author "Fisher, B."
    And I click the first search result
    Then the current reference should be "Fisher, B. 1995b. Fisher's book. Ants 1:1-2."

  # There's a problem getting the search type selector to pick the right one
  #Scenario: Searching
    #When I go to the reference popup widget test page
    #And I search for "bolton"
    #Then I should see "Bolton's book"
    #* I should see "Fisher Bolton book"
    #* I should not see "Bert's book"
    #* I should not see "Fisher's book"

  Scenario: Adding a selected reference
    Given I am logged in
    When I go to the reference popup widget test page
    And I add a reference by Brian Fisher
    Then the current reference should be "Fisher, B.L. 1992. Between Pacific Tides. Ants 2:1."

  Scenario: Editing the selected reference
    Given I am logged in
    When I go to the reference popup widget test page, opened to the first reference
    And I edit the reference
    When I set the authors to "Ward, B.L.; Bolton, B."
    And I set the title to "Ant Title"
    And I save my changes to the current reference
    Then the current reference should be "Ward, B.L.; Bolton, B. 1995b. Ant Title. Ants 1:1-2."

  Scenario: Error when editing reference
    Given I am logged in
    When I go to the reference popup widget test page, opened to the first reference
    And I edit the reference
    When I set the title to ""
    And I save my changes to the current reference
    And I should see "Title can't be blank"
