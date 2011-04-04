Feature: Using the Taxatry
  As a user of AntCat
  I want to view the taxonomy of ants hierarchically
  So that I can choose a taxon easily
    And view its parents and siblings

  Background:
    Given a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "<p><b>Dolichoderinae</b></p>A sweet little subfamily"
      And a genus exists with a name of "Tapinoma" and a subfamily of "Dolichoderinae" and a taxonomic history of "Tapinoma history"
      And a species exists with a name of "sessile" and a genus of "Tapinoma" and a taxonomic history of "sessile history"
    When I go to the Taxatry

  Scenario: Viewing the index page
    Then I should see "Dolichoderinae"
      And I should not see "Tapinoma"

  Scenario: Selecting a subfamily
    When I follow "Dolichoderinae"
    Then "Dolichoderinae" should be selected
      And I should see "A sweet little subfamily"
      And should see "Tapinoma"
      And I should not see "sessile"

  Scenario: Selecting a genus
    When I follow "Dolichoderinae"
    Then "Dolichoderinae" should be selected
    When I follow "Tapinoma"
    Then "Tapinoma" should be selected
      And I should see "Tapinoma history"
      And I should see "sessile"

  Scenario: Selecting a species
    When I follow "Dolichoderinae"
    Then "Dolichoderinae" should be selected
    When I follow "Tapinoma"
    Then "Tapinoma" should be selected
    When I follow "sessile"
    Then "sessile" should be selected
      Then I should see "sessile history"

  Scenario: Searching taxatry
    When I fill in the search box with "Fisher"
