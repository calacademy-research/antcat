@javascript
Feature: Reference field
  Background:
    Given I am logged in
    And these references exist
      | authors                | year | citation_year | title              | citation   |
      | Fisher, B.             | 1995 | 1995b         | Fisher's book      | Ants 1:1-2 |
      | Bolton, B.             | 2010 | 2010 ("2011") | Bolton's book      | Ants 2:1-2 |
      | Fisher, B.; Bolton, B. | 1995 | 1995b         | Fisher Bolton book | Ants 1:1-2 |
      | Hölldobler, B.         | 1995 | 1995b         | Bert's book        | Ants 1:1-2 |

  Scenario: Seeing the field
    When I go to the reference field test page, opened to the first reference
    Then I should see "Fisher, B. 1995b. Fisher's book. Ants 1:1-2 "

  @search
  Scenario: Searching
    When I go to the reference field test page
    And I click the reference field
    And in the reference picker, I search for the author "bolton"
    Then I should see "Bolton's book"
    And I should see "Fisher Bolton book"
    And I should not see "Bert's book"
    And I should not see "Fisher's book"

  @search
  Scenario: Setting a reference when there wasn't one before
    When I go to the reference field test page
    And I click the reference field
    And in the reference picker, I search for the author "Fisher, B."
    And I click the first search result
    And I press "OK"
    Then the authorship field should contain the reference by Fisher

  @search
  Scenario: Searching for multiple authors
    When I go to the reference field test page
    And I click the reference field
    And in the reference picker, I search for the authors "Bolton, B.; Fisher, B."
    Then I should see "Fisher Bolton book"
    And I should not see "Fisher's book"
    And I should not see "Bolton's book"

  @search
  Scenario: Cancelling
    When I go to the reference field test page
    And I click the reference field
    And in the reference picker, I search for the author "Fisher, B."
    And I click the first search result
    And I press "Cancel"
    Then the authorship field should contain "(none)"
