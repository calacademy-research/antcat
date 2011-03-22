Feature: Using the Taxatry
  As a user of AntCat
  I want to view the taxonomy of ants hierarchically
  So that I can choose a taxon easily
    And view its parents and siblings

  Background:
    Given a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "<p><b>Dolichoderinae</b></p>A sweet little subfamily"
      And a genus exists with a name of "Tapinoma" and a subfamily of "Dolichoderinae"
      And a species exists with a name of "sessile" and a genus of "Tapinoma"
    When I go to the Taxatry

  Scenario: Drilling down into the taxonomy
    When I follow "Dolichoderinae"
    Then I should see "Tapinoma"
      And "Dolichoderinae" should be selected
      And I should see "A sweet little subfamily"
    When I follow "Tapinoma"
    Then "Tapinoma" should be selected
      And I should see "sessile"
    When I follow "sessile"
    Then "sessile" should be selected
