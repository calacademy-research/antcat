Feature: Using the Taxatry
  As a user of AntCat
  I want to view the taxonomy of ants hierarchically
  So that I can choose a taxon easily
    And view its parents and siblings

  Background:
    Given a subfamily exists with a name of "Dolichoderinae"
      And a tribe exists with a name of "Attini" and a parent of "Dolichoderinae"
      And a genus exists with a name of "Tapinoma" and a parent of "Attini"
      And a tribe exists with a name of "Ecitonini" and a parent of "Aenictogitoninae"
    When I go to the Taxatry

  Scenario: Drilling down into the taxonomy
    When I follow "Dolichoderinae"
    Then I should not see "Ecitonini"
    When I follow "Attini"
    Then I should see "Tapinoma"
      And "Dolichoderinae" should be selected
      And "Attini" should be selected

  Scenario: Viewing the tribes for all subfamilies
    When I follow "All" in the subfamilies list
    Then I should see "Attini"
      And I should see "Ecitonini"
