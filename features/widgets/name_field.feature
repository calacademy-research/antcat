@javascript
Feature: Name field
  Background:
    Given I am logged in

  Scenario: Find typed taxon
    Given there is a genus "Atta"

    When I go to the name field test page
    And I click the test name field
    And I fill in "name_string" with "Atta"
    And I press "OK"
    Then I should see "Atta" in the name field

  Scenario: Adding a name
    When I go to the name field test page
    And I click the test name field
    And I fill in "name_string" with "Atta wildensis"
    And I press "OK"
    Then I should see "Do you want to add the name Atta wildensis? You can attach it to a taxon later, if desired."
    And I press "Add this name"
    Then I should see "Atta wildensis" in the name field

  Scenario: Cancelling an add
    When I go to the name field test page
    And I click the test name field
    And I fill in "name_string" with "Atta wildensis"
    And I press "OK"
    Then I should see "Do you want to add the name Atta wildensis? You can attach it to a taxon later, if desired."

    When I press "Cancel"
    Then I should not see "Add this name"

  Scenario: Clearing the name
    Given there is a genus "Atta"

    When I go to the name field test page for a name
    And I click the allow_blank name field
    And I fill in "name_string" with ""
    And I press "OK"
    Then I should see "(none)" in the allow_blank name field

  Scenario: Picking a new name in a 'new or 'homomym' field
    When I go to the name field test page
    And I click the new_or_homonym field
    And I fill in "name_string" with "Atta"
    And I press "OK"
    Then I should see "Atta" in the new_or_homonym name field

  Scenario: Picking an existing name in a 'new or homonym' field, and choosing to create a homonym
    Given there is a genus "Atta"

    When I go to the name field test page
    And I click the new_or_homonym field
    And I fill in "name_string" with "Atta"
    And I press "OK"
    Then I should see "This name is in use by another taxon. To create a homonym, click "
    And I should see "Save homonym"
