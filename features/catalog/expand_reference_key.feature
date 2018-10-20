@javascript
Feature: Expanding reference keys
  As an AntCat user
  When I see a short reference key
  I want to be able to click it and see the full reference
  So that I don't have to switch context to see the information I need

  Background:
    Given the Formicidae family exists

  Scenario: Expanding a reference key in the catalog
    When I go to the catalog page for "Formicidae"
    Then I should see the reference key
    And I should not see the reference key expansion

    When I click the reference key
    Then I should see the reference key expansion
    And I should not see the reference key

    When I click the reference key expansion
    Then I should see the reference key
    And I should not see the reference key expansion
