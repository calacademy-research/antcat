Feature: Hiding and showing tribes in the index
  As a user of AntCat
  I want hide tribes sometimes
  Since I may not care about that rank
  And I don't want to have to choose from the tribes

  Background:
    Given a subfamily exists with a name of "Dolichoderinae"
    And a tribe exists with a name of "Dolichoderini" and a subfamily of "Dolichoderinae"
    And a genus exists with a name of "Dolichoderus" and a tribe of "Dolichoderini"
    And a genus exists with a name of "Atta" and a subfamily of "Dolichoderinae"

  Scenario: Hiding tribes
    When I go to the catalog index
      And I follow "Dolichoderinae"
    Then I should see "Dolichoderini" in the index
      And I should not see "show tribes"
    When I follow "hide"
    Then I should not see "Dolichoderini" in the index
      And I should see "show tribes"
      And I should see "Dolichoderus" in the index
      And I should see "Atta" in the index

  Scenario: Showing tribes after selecting a genus with a tribe
    When I go to the catalog index
      And I follow "Dolichoderinae"
      And I follow "hide"
      And I follow "Dolichoderus"
      And I follow "show tribes"
    Then I should see "Dolichoderini" in the index
      And "Dolichoderini" should be selected

  Scenario: Showing tribes after selecting a genus without a tribe
    When I go to the catalog index
      And I follow "Dolichoderinae"
      And I follow "hide"
      And I follow "Atta"
      And I follow "show tribes"
    Then I should see "Dolichoderini" in the index
      And "(incertae sedis)" should be selected in the tribes index
      And I should see "Atta" in the index
      
   Scenario: Hiding tribes after selecting a tribe
    When I go to the catalog index
      And I follow "Dolichoderinae"
      And I follow "Dolichoderini"
      And I follow "hide" in the tribes index
    Then I should not see "Tribes"
      And "Dolichoderinae" should be selected
      
   Scenario: Hiding tribes after selecting a genus
    When I go to the catalog index
      And I follow "Dolichoderinae"
      And I follow "Dolichoderini"
      And I follow "Dolichoderus"
      And I follow "hide" in the tribes index
    Then I should not see "Tribes"
      And "Dolichoderinae" should be selected
      And "Dolichoderus" should be selected

   Scenario: Hiding tribes after selecting "incertae sedis" tribe
    When I go to the catalog index
      And I follow "Dolichoderinae"
      And I follow "(incertae sedis)" in the tribes index
      And I follow "hide" in the tribes index
    Then I should see "Dolichoderinae" in the content
