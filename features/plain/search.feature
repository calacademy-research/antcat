Feature: Searching references
  As a user of ANTBIB
  I want to search for references
  So that I can use one in my paper
    Or see if I have already added it

  Background:
    Given the following entries exist in the bibliography
       |authors     |year         |title                |citation  |
       |Brian Fisher|1995b        |Anthill              |Ants 1:1-2|
       |Barry Bolton|2010 ("2011")|Ants of North America|Ants 2:1-2|

  Scenario: Not searching yet
    When I go to the main page
    Then I should see "Brian Fisher"
      And I should see "Barry Bolton"

  Scenario: Finding one reference for an author
    When I go to the main page
      And I fill in "author" with "Brian"
      And I press "Search"
    Then I should see "Brian Fisher"
      And I should not see "Barry Bolton"

  Scenario: Finding two references for a string
    When I go to the main page
      And I fill in "author" with "b"
      And I press "Search"
    Then I should see "Brian Fisher"
      And I should see "Barry Bolton"

  Scenario: Finding nothing
    When I go to the main page
      And I fill in "author" with "zzzzzz"
      And I press "Search"
    Then I should not see "Brian Fisher"
      And I should not see "Barry Bolton"
      And I should see "No results found"

  Scenario: Clearing the search
    When I go to the main page
      And I fill in "author" with "zzzzzz"
      And I fill in "start_year" with "1972"
      And I fill in "end_year" with "1980"
      And I fill in "journal" with "Playboy"
      And I press "Search"
    Then I should see "No results found"
      And the "author" field should contain "zzzzz"
      And the "start_year" field should contain "1972"
      And the "end_year" field should contain "1980"
      And the "journal" field should contain "Playboy"
    When I press "Clear"
    Then I should not see "No results found"
      And the "author" field should contain ""
      And the "start_year" field should contain ""
      And the "end_year" field should contain ""
      And the "journal" field should contain ""
      And I should see "Brian Fisher"
      And I should see "Barry Bolton"

  Scenario: Searching by year
    When I go to the main page
      And I fill in "start_year" with "1995"
      And I fill in "end_year" with "1995"
      And I press "Search"
    Then I should see "Brian Fisher 1995"
      And I should not see "Barry Bolton 2010"

  Scenario: Searching by one year
    When I go to the main page
      And I fill in "start_year" with "1995"
      And I press "Search"
    Then I should see "Brian Fisher 1995"
      And I should see "Barry Bolton 2010"

  Scenario: Searching by a year range
    Given the following entries exist in the bibliography
     |year  |authors|title |citation  |
     |2009a.|authors|title1|Ants 31:1-2|
     |2010c.|authors|title2|Ants 32:1-2|
     |2011d.|authors|title3|Ants 33:1-2|
     |2012e.|authors|title4|Ants 34:1-2|
    When I go to the main page
      And I fill in "start_year" with "2010"
      And I fill in "end_year" with "2011"
      And I press "Search"
    Then I should see "2010c."
      And I should see "2011d."
      And I should not see "2009a."
      And I should not see "2012e."

  Scenario: Searching by end year
    When I go to the main page
      And I fill in "end_year" with "1995"
      And I press "Search"
    Then I should see "Brian Fisher 1995"
      And I should not see "Barry Bolton 2010"

  Scenario: Searching by start year
    When I go to the main page
      And I fill in "start_year" with "2010"
      And I press "Search"
    Then I should not see "Brian Fisher 1995"
      And I should see "Barry Bolton 2010"
    
  Scenario: Searching by author and year
    Given the following entries exist in the bibliography
       |authors     |year |title|citation  |
       |Brian Fisher|1895a|title5|Ants 11:1-2|
       |Brian Fisher|1810b|title6|Ants 12:1-2|
       |Barry Bolton|1810e|title7|Ants 13:1-2|
       |Barry Bolton|1895d|title8|Ants 14:1-2|
    When I go to the main page
      And I fill in "author" with "brian"
      And I fill in "start_year" with "1895"
      And I fill in "end_year" with "1895"
      And I press "Search"
    Then I should see "Brian Fisher 1895"
      And I should not see "Brian Fisher 1810"
      And I should not see "Barry Bolton 1810"
      And I should not see "Barry Bolton 1895"

  Scenario: Searching by journal title
    Given the following entries exist in the bibliography
       |citation              |authors|title|year|
       |Acta Informatica 1:222|authors|title9|year|
       |Science (3)1:444      |authors|title10|year|
    When I go to the main page
      And I fill in "journal" with "Science"
      And I press "Search"
    Then I should see "Science"
      And I should not see "Acta Informatica"

