Feature: Searching references
  As a user of ANTBIB
  I want to search for references
  So that I can use one in my paper
    Or see if I have already added it

  Background:
    Given the following entries exist in the bibliography
       |authors     |year         |numeric_year|title|citation|
       |Brian Fisher|1995b        |1995        |title|citation|
       |Barry Bolton|2010 ("2011")|2010        |title|citation|

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
     |year  |numeric_year|authors|title|citation|
     |2009a.|2009        |authors|title|citation|
     |2010c.|2010        |authors|title|citation|
     |2011d.|2011        |authors|title|citation|
     |2012e.|2012        |authors|title|citation|
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
       |authors     |year |numeric_year|title|citation|
       |Brian Fisher|1995a|1995        |title|citation|
       |Brian Fisher|2010b|2010        |title|citation|
       |Barry Bolton|2010e|2010        |title|citation|
       |Barry Bolton|1995d|1995        |title|citation|
    When I go to the main page
      And I fill in "author" with "fisher"
      And I fill in "start_year" with "1995"
      And I fill in "end_year" with "1995"
      And I press "Search"
    Then I should see "Brian Fisher 1995"
      And I should not see "Brian Fisher 2010"
      And I should not see "Barry Bolton 2010"
      And I should not see "Barry Bolton 1995"

  Scenario: Searching by journal title
    Given the following entries exist in the bibliography
       |citation|journal_title|authors|title|year|
       |Acta Informatica 1:222|Acta Informatica|authors|title|year|
       |Science (3)1:444|Science|authors|title|year|
    When I go to the main page
      And I fill in "journal" with "Science"
      And I press "Search"
    Then I should see "Science"
      And I should not see "Acta Informatica"

