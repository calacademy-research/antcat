Feature: Using the Taxatry
  As a user of AntCat
  I want to view the taxonomy of ants hierarchically
  So that I can choose a taxon easily
    And view its parents and siblings

  Background:
    Given a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "<p><b>Dolichoderinae</b></p>A sweet little subfamily"
      And a genus exists with a name of "Tapinoma" and a subfamily of "Dolichoderinae" and a taxonomic history of "Tapinoma history"
      And a genus exists with a name of "Atta" and a subfamily of "Dolichoderinae" and a taxonomic history of "Atta history"
      And a species exists with a name of "sessile" and a genus of "Tapinoma" and a taxonomic history of "sessile history"
      And a species exists with a name of "emeryi" and a genus of "Tapinoma" and a taxonomic history of "emeryi history"
      And a species exists with a name of "emeryi" and a genus of "Atta" and a taxonomic history of "atta emeryi history"
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

  Scenario: Searching taxatry when only one result
    When I fill in the search box with "sessile"
      And I press "Go" by the search box
    Then I should see "sessile history"

  Scenario: Searching taxatry when no results
    When I fill in the search box with "asdfjl;jsdf"
      And I press "Go" by the search box
    Then I should see "No results found"

  Scenario: Searching taxatry when more than one result
    When I fill in the search box with "emeryi"
      And I press "Go" by the search box
    Then I should see "Dolichoderinae Tapinoma emeryi"
      And I should see "Dolichoderinae Atta emeryi"
      And I should see "emeryi history"
    When I follow "Dolichoderinae Atta emeryi"
    Then I should see "atta emeryi history"
      And I should see "Dolichoderinae Tapinoma emeryi"
      And "Dolichoderinae Atta emeryi" should be selected

  Scenario: Searching taxatry for a 'beginning with' match
    When I fill in the search box with "ses"
      And I select "beginning with" from "search_type"
      And I press "Go" by the search box
    Then I should see "sessile history"

  Scenario: Finding a genus without a subfamily
    Given a genus exists with a name of "Monomorium" and a taxonomic history of "Monomorium history"
    When I fill in the search box with "Monomorium"
      And I press "Go" by the search box
    Then I should see "Monomorium history"

  Scenario: Closing the search results
    When I fill in the search box with "emeryi"
      And I press "Go" by the search box
    Then I should see "Dolichoderinae Tapinoma emeryi"
      And I should see "Dolichoderinae Atta emeryi"
      And I should see "atta emeryi history"
    When I press "Clear"
    Then I should see "atta emeryi history"
      And I should not see "Dolichoderinae Tapinoma emeryi"

  Scenario: Keeping search results open even after finding another taxon
    When I fill in the search box with "emeryi"
      And I press "Go" by the search box
    Then I should see "Dolichoderinae Tapinoma emeryi"
      And I should see "Dolichoderinae Atta emeryi"
      And I should see "atta emeryi history"
    When I follow "emeryi"
    Then I should see "atta emeryi history"
      And I should see "Dolichoderinae Tapinoma emeryi"
