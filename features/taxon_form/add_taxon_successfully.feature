Feature: Adding a taxon successfully
  Background:
    Given I am logged in
    And this reference exists
      | author | title | citation_year |
      | Fisher | Ants  | 2004          |
    And the default reference is "Fisher, 2004"
    And there is a subfamily "Formicinae"

  @javascript
  Scenario: Adding a genus
    Given there is a genus "Eciton"

    When I go to the catalog page for "Formicinae"
    And I follow "Add genus"
    And I click the name field
      And I set the name to "Atta"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Eciton"
      And I press "OK"
    And I click the type name field
      And I set the type name to "Atta major"
      And I press "OK"
      And I press "Add this name"
    And I press "Save"
    Then I should be on the catalog page for "Atta"
    And I should see "Eciton" in the protonym

    When I go to the catalog page for "Formicinae"
    Then I should see "Atta" in the index

  @javascript
  Scenario: Adding a genus which has a tribe
    Given tribe "Ecitonini" exists in that subfamily

    When I go to the catalog page for "Ecitonini"
    And I follow "Add genus"
    And I click the name field
      And I set the name to "Eciton"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Eciton"
      And I press "OK"
    And I click the type name field
      And I set the type name to "Eciton major"
      And I press "OK"
      And I press "Add this name"
    And I press "Save"
    Then I should be on the catalog page for "Eciton"

  @javascript
  Scenario: Adding a subgenus
    Given there is a genus "Camponotus"

    When I go to the catalog page for "Camponotus"
    And I follow "Add subgenus"
    And I click the name field
      And I set the name to "Camponotus (Mayria)"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Mayria"
      And I press "OK"
      And I press "Add this name"
    And I click the type name field
      And I set the type name to "Mayria madagascarensis"
      And I press "OK"
      And I press "Add this name"
    And I press "Save"
    Then I should be on the catalog page for "Camponotus (Mayria)"
    And I should see "Mayria" in the protonym

    When I go to the catalog page for "Camponotus"
    And I follow "Subgenera"
    Then I should see "Mayria" in the index

  @javascript
  Scenario: Adding a species
    Given there is a genus "Eciton"

    When I go to the catalog page for "Eciton"
    And I follow "Add species"
    And I click the name field
      And I set the name to "Eciton major"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Eciton major"
      And I press "OK"
      And WAIT_FOR_JQUERY
    And I press "Save"
    Then I should be on the catalog page for "Eciton major"
    And I should see "Eciton major" in the protonym
    And I should see "Add another"

  @javascript
  Scenario: Adding a species to a subgenus
    Given there is a subfamily "Dolichoderinae"
    And tribe "Dolichoderini" exists in that subfamily
    And genus "Dolichoderus" exists in that tribe
    And subgenus "Dolichoderus (Subdolichoderus)" exists in that genus

    When I go to the catalog page for "Dolichoderus (Subdolichoderus)"
    And I follow "Add species"
    And I click the name field
      And I set the name to "Dolichoderus major"
      And I press "OK"
    And I click the protonym name field
      # TODO: this only works because it's already set to "Dolichoderus major".
      And I set the protonym name to "Dolichoderus major"
      And I press "OK"
      And WAIT_FOR_JQUERY
    And I press "Save"
    Then I should be on the catalog page for "Dolichoderus major"
    And I should see "Dolichoderus major" in the protonym

  @javascript
  Scenario: Adding a subspecies
    Given there is a species "Eciton major" with genus "Eciton"

    When I go to the catalog page for "Eciton major"
    And I follow "Add subspecies"
    And I click the name field
      And I set the name to "Eciton major infra"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Eciton major infra"
      And I press "OK"
      And WAIT_FOR_JQUERY
    And I press "Save"
    Then I should be on the catalog page for "Eciton major infra"
    And I should see "infra" in the index
    And I should see "Eciton major infra" in the protonym

  @javascript
  Scenario: Adding a subfamily
    Given the Formicidae family exists

    When I go to the main page
    And I follow "Add subfamily"
    And I click the name field
      And I set the name to "Dorylinae"
      And I press "OK"
    And I click the protonym name field
      Then the protonym name field should contain "Dorylinae"
      When I press "OK"
    And I click the type name field
      And I set the type name to "Atta"
      And I press "OK" in "#type_name_field"
      And I press "Add this name"
    When I press "Save"
    Then I should be on the catalog page for "Dorylinae"
    And I should see "Dorylinae" in the protonym

    When I go to the catalog page for "Formicinae"
    And I follow "Formicidae subfamilies"
    Then I should see "Dorylinae" in the index
    And I should not see "Add another"

  @javascript
  Scenario: Adding a tribe
    When I go to the catalog page for "Formicinae"
    And I follow "Add tribe"
    And I click the name field
      And I set the name to "Dorylini"
      And I press "OK"
    And I click the protonym name field
      Then the protonym name field should contain "Dorylini"
      And I press "OK"
      And WAIT_FOR_JQUERY
    And I press "Save"
    Then I should be on the catalog page for "Dorylini"
    And I should see "Dorylini" in the protonym

    When I go to the catalog page for "Formicinae"
    And I follow "Formicinae tribes"
    Then I should see "Tribe of Formicinae: Dorylini"
