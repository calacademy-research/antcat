Feature: Searching references
  As a user of ANTBIB
  I want to search for references
  So that I can use one in my paper
    Or see if I have already added it

  Background:
    Given the following entries exist in the bibliography
      |authors    |year         |title                |citation  |
      |Fisher, B. |1995b        |Anthill              |Ants 1:1-2|
      |Forel, M.  |1995b        |Formis               |Ants 1:1-2|
      |Bolton, B. |2010 ("2011")|Ants of North America|Ants 2:1-2|

  Scenario: Not searching yet
    When I go to the main page
    Then I should see "Fisher, B."
      And I should see "Forel, M."
      And I should see "Bolton, B."

  Scenario: Finding one reference for an author
    When I go to the main page
      And I fill in "q" with "Fisher"
      And I press "Search"
    Then I should see "Fisher, B."
      And I should not see "Bolton, B."
      And I should not see "Forel, M."

  Scenario: Finding nothing
    When I go to the main page
      And I fill in "q" with "zzzzzz"
      And I press "Search"
    Then I should not see "Fisher, B."
      And I should not see "Bolton, B."
      And I should not see "Forel, M."
      And I should see "No results found"

  Scenario: Clearing the search
    When I go to the main page
      And I fill in "q" with "zzzzzz 1972-1980"
      And I press "Search"
    Then I should see "No results found"
      And the "q" field should contain "zzzzzz 1972-1980"
    When I press "Clear"
    Then I should not see "No results found"
      And the "q" field should contain ""
      And I should see "Fisher, B."
      And I should see "Bolton, B."
      And I should see "Forel, M."

  Scenario: Searching by year
    When I go to the main page
      And I fill in "q" with "1995"
      And I press "Search"
    Then I should see "Fisher, B. 1995"
      And I should see "Forel, M. 1995"
      And I should not see "Bolton, B. 2010"

  Scenario: Searching by a year range
    Given the following entries exist in the bibliography
     |year  |authors|title |citation   |
     |2009a.|authors|title1|Ants 31:1-2|
     |2010c.|authors|title2|Ants 32:1-2|
     |2011d.|authors|title3|Ants 33:1-2|
     |2012e.|authors|title4|Ants 34:1-2|
    When I go to the main page
      And I fill in "q" with "2010-2011"
      And I press "Search"
    Then I should see "2010c."
      And I should see "2011d."
      And I should not see "2009a."
      And I should not see "2012e."

  Scenario: Searching by author and year
    Given the following entries exist in the bibliography
       |authors     |year |title|citation    |
       |Fisher, B.|1895a|title5|Ants 11:1-2|
       |Fisher, B.|1810b|title6|Ants 12:1-2|
       |Bolton, B.|1810e|title7|Ants 13:1-2|
       |Bolton, B.|1895d|title8|Ants 14:1-2|
    When I go to the main page
      And I fill in "q" with "fisher 1895-1895"
      And I press "Search"
    Then I should see "Fisher, B. 1895"
      And I should not see "Fisher, B. 1810"
      And I should not see "Bolton, B. 1810"
      And I should not see "Bolton, B. 1895"

  Scenario: Searching by ID
    Given there is a reference with ID 50000 for Dolerichoderinae
    When I go to the main page
      And I fill in "q" with "50000"
      And I press "Search"
    Then I should see "Dolerichoderinae"
    When I fill in "q" with "10000"
      And I press "Search"
    Then I should not see "Dolerichoderinae"
