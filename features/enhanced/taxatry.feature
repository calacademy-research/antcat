Feature: Using the Taxatry
  As a user of AntCat
  I want to view the taxonomy of ants hierarchically
  So that I can choose a taxon easily
    And view its parents and siblings

  Background:
    Given a subfamily exists with a name of "Dolichoderinae"
      And a tribe exists with a name of "Attini" and a subfamily of "Dolichoderinae"
      And a genus exists with a name of "Tapinoma" and a tribe of "Attini"
      And a species exists with a name of "sessile" and a genus of "Tapinoma"
      And a tribe exists with a name of "Ecitonini" and a subfamily of "Aenictogitoninae"
    When I go to the Taxatry

  Scenario: Seeing the initial subfamilies
    Then I should see "Dolichoderinae"

  Scenario: Viewing the tribes for a subfamily
    When I follow "Dolichoderinae"
    Then I should see "Attini"

  Scenario: Not showing the tribes for a subfamily
    When I uncheck "Show tribes?"
    When I follow "Dolichoderinae"
    Then I should not see "Attini"
      And I should see "Tapinoma"

  Scenario: Drilling down into the taxonomy
    When I follow "Dolichoderinae"
    Then I should not see "Ecitonini"
    When I follow "Attini"
    Then I should see "Tapinoma"
      And "Dolichoderinae" should be selected
      And "Attini" should be selected
    When I follow "Tapinoma"
    Then "Tapinoma" should be selected
      And I should see "sessile"

  Scenario: Viewing the tribes for all subfamilies
    When I follow "All" in the subfamilies list
    Then I should see "Attini"
      And I should see "Ecitonini"

  Scenario: Viewing the genera for all subfamilies
    When I uncheck "Show tribes?"
      And I follow "All" in the subfamilies list
    Then I should not see "Attini"
      And I should see "Tapinoma"
