Feature: Using the Taxatry
  As a user of AntCat
  I want to view the taxonomy of ants hierarchically
  So that I can choose a taxon easily
    And view its parents and siblings

  Scenario: Viewing subfamilies
    Given a subfamily exists with a name of "Dolichoderinae"
    When I go to the Taxatry
    Then I should see "Dolichoderinae"

  Scenario: Viewing the tribes of a subfamily
    Given a subfamily exists with a name of "Dolichoderinae"
      And a tribe exists with a name of "Attini" and a parent of "Dolichoderinae"
    When I go to the Taxatry
      And I follow "Dolichoderinae"
    Then I should see "Attini"

