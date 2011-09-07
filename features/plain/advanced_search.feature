Feature: Advanced search
  As any old user of AntCat
  I want to do more than just search for text/year/id/author in one field
  I want to be able to specify author names and have them only searched for
    in the author names
  And so on
  So that I can quickly find a reference

  Scenario: Searching for one author only
    Given I am logged in
      And the following references exist
      |authors              |year |title                |citation  |
      |Fisher, B.;Bolton, B.|1995b|Anthill              |Ants 1:1-2|
      |Forel, M.            |1995b|Formis               |Ants 1:1-2|
      |Bolton, B.           |2010 |Ants of North America|Ants 2:1-2|
    When I go to the references page
    Then I should see "Anthill"
      And I should see "Ants of North America"
      And I should see "Formis"
    When I fill in the search authors box with "Bolton, B."
      And I press "Go" by the search box
    Then I should see "Anthill"
      And I should see "Ants of North America"
      And I should not see "Formis"
