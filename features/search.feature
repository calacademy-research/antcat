Feature: Searching references
  As a user of ANTBIB
  I want to search for references
  So that I can use one in my paper
    Or see if I have already added it

  Background:
    Given the following entries exist in the bibliography
       |authors|
       |Brian Fisher|
       |Barry Bolton|

  Scenario: Not searching yet
    When I go to the main page
    Then I should see "Brian Fisher"
      And I should see "Barry Bolton"

  Scenario: Finding one reference for an author
    When I go to the main page
    When I fill in "author" with "Brian"
      And I press "Search"
    Then I should see "Brian Fisher"
      And I should not see "Barry Bolton"

  Scenario: Finding two references for a string
    When I go to the main page
    When I fill in "author" with "b"
      And I press "Search"
    Then I should see "Brian Fisher"
      And I should see "Barry Bolton"

  Scenario: Finding nothing
    When I go to the main page
    When I fill in "author" with "zzzzzz"
      And I press "Search"
    Then I should not see "Brian Fisher"
      And I should not see "Barry Bolton"
      And I should see "No results found"
