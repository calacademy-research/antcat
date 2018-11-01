@javascript
Feature: Create combinations
  Background:
    Given I am logged in as a catalog editor

  Scenario: Changing a species's genus by using the helper link
    Given there is a species "Atta major" with genus "Atta"
    And there is a genus "Eciton"

    When I go to the catalog page for "Atta major"
    And I follow "Create combination"
    And I set the new parent field to "Eciton"
    And I press "Select..."
    Then I should see "Would you like to create a new combination under this parent?"

    When I follow "Yes, create new combination"
    Then the name button should contain "Eciton major"

    When I press "Save"
    Then I should be on the catalog page for "Eciton major"
    And the name in the header should be "Eciton major"

    When I go to the catalog page for "Atta major"
    Then I should see "see Eciton major"

  # Change parent from A -> B -> A
  Scenario: Merging back when we have the same protonym
    Given there is species "Atta major" and another species "Beta major" shared between protonym genus "Atta" and later genus "Beta"

    When I go to the catalog page for "Beta major"
    And I follow "Create combination"
    And I set the new parent field to "Atta"
    And I press "Select..."
    Then I should see "This new combination looks a lot like existing combinations"
    And I should see "Atta major"
    And I should see "return to a previous usage"

    When I follow "Merge back"
    Then I should see "new merge back into original Atta major"

  Scenario: Creating a secondary junior homonym
    Given there is species "Atta major" and another species "Beta major" shared between protonym genus "Atta" and later genus "Beta"

    When I go to the catalog page for "Beta major"
    And I follow "Create combination"
    And I set the new parent field to "Atta"
    And I press "Select..."
    Then I should see "This new combination looks a lot like existing combinations"
    And I should see "Atta major"
    And I should see "return to a previous usage"

    When I follow "Create homonym"
    Then I should see "new secondary junior homonym of Atta"

  Scenario: Merging when we have distinct protonyms
    Given there is a species "Atta major" with genus "Atta"
    And there is a species "Beta major" with genus "Beta"

    When I go to the catalog page for "Beta major"
    And I follow "Create combination"
    And I set the new parent field to "Atta"
    And I press "Select..."
    Then I should see "This new combination looks a lot like existing combinations"
    And I should not see "return to a previous usage"
    And I should see "create secondary junior homonym"

    When I follow "Create homonym"
    Then I should see "new secondary junior homonym of Atta"

  Scenario: Detecting a possible secondary homonym when there is a subspecies name conflict
    Given there is a subspecies "Solenopsis speccus subbus" which is a subspecies of "Solenopsis speccus" in the genus "Solenopsis"
    And there is a subspecies "Atta betus subbus" which is a subspecies of "Atta betus" in the genus "Atta"

    When I go to the catalog page for "Solenopsis speccus subbus"
    And I follow "Create combination"
    And I set the new parent field to "Atta betus"
    And I press "Select..."
    Then I should see "This new combination looks a lot like existing combinations"
    And I should see "Atta betus subbus"
    And I should see "create secondary junior homonym"

    When I follow "Create homonym"
    Then I should see "new secondary junior homonym of Atta betus"

    When I press "Save"
    Then I should see "Atta betus subbus"
    And I should see "unresolved junior homonym"
    And I should see "This taxon has been changed; changes awaiting approval"

  Scenario: Changing a species's genus twice by using the helper link
    Given there is an original species "Atta major" with genus "Atta"
    And there is a genus "Becton"
    And there is a genus "Chatsworth"

    # Change parent from A -> B
    When I go to the catalog page for "Atta major"
    And I follow "Create combination"
    And I set the new parent field to "Becton"
    And I press "Select..."
    And I follow "Yes, create new combination"
    And I press "Save"
    And I wait

    # Change parent from B -> C
    When I go to the catalog page for "Becton major"
    And I follow "Create combination"
    And I set the new parent field to "Chatsworth"
    And I press "Select..."
    And I follow "Yes, create new combination"
    Then the name button should contain "Chatsworth major"

    When I press "Save"
    # We are now on the catalog page after doing A -> B -> C
    Then I should be on the catalog page for "Chatsworth major"
    And the name in the header should be "Chatsworth major"

    When I go to the catalog page for "Atta major"
    Then I should see "see Chatsworth major"

    When I go to the catalog page for "Becton major"
    Then I should see "an obsolete combination of Chatsworth major"

  Scenario: Changing a subspecies's species
    Given there is a species "Atta major" with genus "Atta"
    And there is a species "Eciton nigra" with genus "Eciton"
    And there is a subspecies "Atta major minor" which is a subspecies of "Atta major"

    When I go to the catalog page for "Atta major minor"
    And I follow "Create combination"
    And I set the new parent field to "Eciton nigra"
    And I press "Select..."
    And I follow "Yes, create new combination"
    And I press "Save"
    Then I should be on the catalog page for "Eciton nigra minor"
    And the name in the header should be "Eciton nigra minor"

  Scenario: Fixing a subspecies without a species
    Given there is a species "Crematogaster menilekii"
    And there is a subspecies "Crematogaster menilekii proserpina" without a species

    When I go to the edit page for "Crematogaster menilekii proserpina"
    Then I should see "this subspecies has no species, please set one"

    When I set "taxon_species_id" to "Crematogaster menilekii" [select-two]
    And I press "Save"
    Then I should be on the catalog page for "Crematogaster menilekii proserpina"
    And the "species" of "Crematogaster menilekii proserpina" should be "Crematogaster menilekii"
