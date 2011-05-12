Feature: Using the Taxatry index with Tribes
  As a user of AntCat
  I want to view tribes in the ant taxonomy
  So that I can see information about the tribe and what's in it

  Background:
    Given a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "<p><b>Dolichoderinae</b></p>Dolichoderinae history"
      And a tribe exists with a name of "Attini" and a subfamily of "Dolichoderinae" and a taxonomic history of "<p><b>Attini</b></p>Attini history"
      And a genus exists with a name of "Cariridris" and no subfamily and a taxonomic history of "<p><b>Cariridris</b></p>Cariridris history"
      And a genus exists with a name of "Atta" and a tribe of "Attini" and a taxonomic history of "<p><b>Atta</b></p>Atta history"
      And a species exists with a name of "rubosa" and a genus of "Atta" and a taxonomic history of "rubosa history"
    When I go to the Taxatry index

  Scenario: Showing tribes for a subfamily
    Then I should see "Dolichoderinae"
      And I should not see "Tribes"
    When I follow "Dolichoderinae"
    Then I should see "Tribes"
      And I should see "Attini"
      And I should see "Dolichoderinae history"

  Scenario: Selecting a tribe
    When I follow "Dolichoderinae"
      And I follow "Attini"
    Then I should see "Attini history"
      And I should see "Atta"
      And "Attini" should be selected

  Scenario: Selecting a genus
    When I follow "Dolichoderinae"
      And I follow "Attini"
      And I follow "Atta"
    Then I should see "Atta history"
      And I should see "rubosa"
      And "Attini" should be selected
      And "Atta" should be selected

  Scenario: Selecting a species
    When I follow "Dolichoderinae"
      And I follow "Attini"
      And I follow "Atta"
      And I follow "rubosa"
    Then I should see "rubosa history"
      And "Attini" should be selected
      And "Atta" should be selected
      And "rubosa" should be selected

  Scenario: Showing genera without subfamilies
    And I follow "(incertae sedis)"
      Then I should not see "Tribes"
        And I should see "Genera"
        And I should see "Cariridris"

