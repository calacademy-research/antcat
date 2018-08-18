@javascript
Feature: Changing parent genus, species, tribe or subfamily
  Background:
    Given I am logged in

  Scenario: Changing a species's genus
    Given there is a genus "Atta"
    And there is a genus "Eciton"
    And there is a species "Atta major" with genus "Atta"

    When I go to the edit page for "Atta major"
    And I click the parent name field
    And I set the parent name to "Eciton"
    And I press "OK"
    Then I should see "Would you like to create a new combination under this parent?"

    When I press "Yes, create new combination"
    And I press "Save"
    Then I should be on the catalog page for "Eciton major"
    And the name in the header should be "Eciton major"

  Scenario: Changing a species's genus by using the helper link
    Given there is a species "Atta major" with genus "Atta"
    And there is a genus "Eciton"

    When I go to the edit page for "Atta major"
    And I click the parent name field
    And I set the parent name to "Eciton"
    And I press "OK"
    Then I should see "Would you like to create a new combination under this parent?"

    When I press "Yes, create new combination"
    Then the name button should contain "Eciton major"

    When I press "Save"
    Then I should be on the catalog page for "Eciton major"
    And the name in the header should be "Eciton major"

    When I go to the catalog page for "Atta major"
    Then I should see "see Eciton major"

  # Change parent from A -> B -> A
  Scenario: Merging back when we have the same protonym
    Given there is species "Atta major" and another species "Beta major" shared between protonym genus "Atta" and later genus "Beta"

    When I go to the edit page for "Beta major"
    And I click the parent name field
    And I set the parent name to "Atta"
    And I press "OK"
    Then I should see "This new combination looks a lot like existing combinations"
    And I should see "Choose a representation"
    And I should see "Atta major: (Fisher"
    And I should see " return to a previous usage"
    And I should see "Create secondary junior homonym of Atta major"

    When I press "Yes, create new combination"
    Then I should see "new merge back into original Atta major"

    When I press "Save"

  Scenario: Creating a secondary junior homonym
    Given there is species "Atta major" and another species "Beta major" shared between protonym genus "Atta" and later genus "Beta"

    When I go to the edit page for "Beta major"
    And I click the parent name field
    And I set the parent name to "Atta"
    And I press "OK"
    Then I should see "This new combination looks a lot like existing combinations"
    And I should see "Choose a representation"
    And I should see "Atta major: (Fisher"
    And I should see "return to a previous usage"
    And I should see "Create secondary junior homonym of Atta major"

    When I choose "homonym"
    And I press "Yes, create new combination"
    Then I should see "new secondary junior homonym of species of Atta"

  Scenario: Merging when we have distinct protonyms
    Given there is a species "Atta major" with genus "Atta"
    And there is a species "Beta major" with genus "Beta"

    When I go to the edit page for "Beta major"
    And I click the parent name field
    And I set the parent name to "Atta"
    And I press "OK"
    Then I should see "This new combination looks a lot like existing combinations"
    And I should see "Choose a representation"
    And I should not see "Atta major: (Fisher5, 2015) return to a previous usage"
    And I should see "This would become a secondary junior homonym; name conflict with distinct authorship"

    When I choose "homonym"
    And I press "Yes, create new combination"
    Then I should see "new secondary junior homonym of species of Atta"

  Scenario: Detecting a possible secondary homonym when there is a subspecies name conflict
    Given there is a subspecies "Solenopsis speccus subbus" which is a subspecies of "Solenopsis speccus" in the genus "Solenopsis"
    And there is a subspecies "Atta betus subbus" which is a subspecies of "Atta betus" in the genus "Atta"

    When I go to the edit page for "Solenopsis speccus subbus"
    And I click the parent name field
    And I set the parent name to "Atta betus"
    And I press "OK"
    Then I should see "This new combination looks a lot like existing combinations"
    And I should see "Atta betus subbus"
    And I should see "This would become a secondary junior homonym; name conflict with distinct authorship"

    When I choose "secondary_junior_homonym"
    And I press "Yes, create new combination"
    Then I should see "new secondary junior homonym of subspecies of Atta betus"

    When I press "Save"
    Then I should see "Atta betus subbus"
    And I should see "unresolved junior homonym"
    And I should see "This taxon has been changed; changes awaiting approval"

  Scenario: Changing a species's genus twice by using the helper link
    Given there is an original species "Atta major" with genus "Atta"
    And there is a genus "Becton"
    And there is a genus "Chatsworth"

    # Change parent from A -> B
    When I go to the edit page for "Atta major"
    And I click the parent name field
    And I set the parent name to "Becton"
    And I press "OK"
    Then I should see "Would you like to create a new combination under this parent?"

    When I press "Yes, create new combination"
    And I press "Save"
    And I wait

    # Change parent from B -> C
    And I go to the edit page for "Becton major"
    And I click the parent name field
    And I set the parent name to "Chatsworth"
    And I press "OK"
    Then I should see "Would you like to create a new combination under this parent?"

    When I press "Yes, create new combination"
    Then the name button should contain "Chatsworth major"

    When I press "Save"
    # We are now on the catalog page after doing A -> B -> C
    Then I should be on the catalog page for "Chatsworth major"
    And the name in the header should be "Chatsworth major"

    When I go to the catalog page for "Atta major"
    Then I should see "see Chatsworth major"

    When I go to the catalog page for "Becton major"
    Then I should see "an obsolete combination of Chatsworth major"

  Scenario: Changing a species's genus, duplicating an existing taxon
    Given there is a species "Atta pilosa" with genus "Atta"
    And there is a species "Eciton pilosa" with genus "Eciton"

    When I go to the edit page for "Atta pilosa"
    And I click the parent name field
    And I set the parent name to "Eciton"
    And I press "OK"
    Then I should see "This new combination looks a lot like existing combinations"

  Scenario: Changing a subspecies's species
    Given there is a species "Atta major" with genus "Atta"
    And there is a species "Eciton nigra" with genus "Eciton"
    And there is a subspecies "Atta major minor" which is a subspecies of "Atta major"

    When I go to the edit page for "Atta major minor"
    And I click the parent name field
    And I set the parent name to "Eciton nigra"
    And I press "OK"
    And I press "Yes, create new combination"
    And I press "Save"
    Then I should be on the catalog page for "Eciton nigra minor"
    And the name in the header should be "Eciton nigra minor"

  Scenario: Parent field not visible for the family
    Given the Formicidae family exists

    When I go to the edit page for "Formicidae"
    Then I should not see the parent name field

  Scenario: Parent field not visible while adding
    Given there is a species "Eciton major" with genus "Eciton"

    When I go to the catalog page for "Eciton major"
    And I follow "Add subspecies"
    Then I should be on the new taxon page
    And I should not see the parent name field

  Scenario: Fixing a subspecies without a species
    Given there is a species "Crematogaster menilekii"
    And there is a subspecies "Crematogaster menilekii proserpina" without a species

    When I go to the edit page for "Crematogaster menilekii proserpina"
    And I click the parent name field
    And I set the parent name to "Crematogaster menilekii"
    And I press "OK"
    And I press "Yes, update parent record only"
    And I press "Save"
    Then I should be on the catalog page for "Crematogaster menilekii proserpina"

  Scenario: Changing a genus's tribe
    Given there is a tribe "Attini"
    And genus "Atta" exists in that tribe
    And there is a tribe "Ecitoni"

    When I go to the edit page for "Atta"
    And I click the parent name field
    And I set the parent name to "Ecitoni"
    And I press "OK"
    And I wait
    And I press "Save"
    And I follow " tribes"
    Then I should be on the catalog page for "Atta"
    And "Ecitoni" should be selected

  Scenario: Changing a genus's subfamily
    Given the Formicidae family exists
    And there is a subfamily "Attininae"
    And genus "Atta" exists in that subfamily
    And there is a subfamily "Ecitoninae"

    When I go to the edit page for "Atta"
    And I click the parent name field
    And I set the parent name to "Ecitoninae"
    And I press "OK"
    And I press "Save"
    And I follow "Formicidae subfamilies"
    Then I should be on the catalog page for "Atta"
    And "Ecitoninae" should be selected

  Scenario: Setting a genus's parent to blank
    Given PENDING: TODO selected only works for the incertae sedis / all genera links themselves, not child taxa
    Given there is a subfamily "Attininae"
    And genus "Atta" exists in that subfamily

    When I go to the edit page for "Atta"
    And I click the parent name field
    And I set the parent name to ""
    And I press "OK"
    And I press "Save"
    Then I should be on the catalog page for "Atta"
    And "Incertae sedis" should be selected in the subfamilies index

  Scenario: Setting a genus's parent to a nonexistent name
    Given there is a subfamily "Attininae"
    And genus "Atta" exists in that subfamily

    When I go to the edit page for "Atta"
    And I click the parent name field
    And I set the parent name to "Appaloosa"
    And I press "OK"
    Then I should see "This must be the name of an existing taxon"

  # Pick a name that has no duplicates.
  # It should have simple dialogs and then warp to a page that has the fix.
  Scenario: Merging back when we have the same protonym
    Given there is a species "Atta major" with genus "Atta"
    And there is a subspecies "Atta major minor" without a species

    When I go to the edit page for "Atta major minor"
    Then I should see "subspecies of (no species)"

    When I click the parent name field
    And I set the parent name to "Atta major"
    And I press "OK"
    Then I should see "Confirm parent species change"
    And I should see "Atta major: "
    And I should see "Choose a parent species:"

    When I press "Yes, update parent record only"
    Then I should see "subspecies of Atta major"

  Scenario: Merging back when we have the same protonym without superadmin
    Given there is a subspecies "Batta speccus subbus" which is a subspecies of "Batta speccus" in the genus "Batta"
    And there is a subspecies "Atta speccus subbus" which is a subspecies of "Atta speccus" in the genus "Atta"

    When I go to the edit page for "Atta speccus subbus"
    Then I should see "subspecies of Atta speccus"

    When I click the parent name field
    And I set the parent name to "Batta speccus"
    And I press "OK"
    Then I should see "This new combination looks a lot like existing combinations."
    And I should see "Batta speccus subbus: "
    And I should see " This would become a secondary junior homonym; name conflict with distinct authorship"
    And I should see "Create secondary junior homonym of Batta speccus subbus: "
    And I should not see "No, just change the parent"
    And I should see "Yes, create new combination"

  # Pick a name that has duplicates. Force a choice.
  Scenario: Merging back when we have the same protonym with superadmin
    Given I log in as a superadmin
    And there is a subspecies "Batta speccus subbus" which is a subspecies of "Batta speccus" in the genus "Batta"
    And there is a subspecies "Atta speccus subbus" which is a subspecies of "Atta speccus" in the genus "Atta"

    When I go to the edit page for "Atta speccus subbus"
    Then I should see "subspecies of Atta speccus"

    When I click the parent name field
    And I set the parent name to "Batta speccus"
    And I press "OK"
    Then I should see "This new combination looks a lot like existing combinations."
    And I should see "Batta speccus subbus: "
    And I should see "This would become a secondary junior homonym; name conflict with distinct authorship"
    And I should see "Create secondary junior homonym of Batta speccus subbus:"
    And I should see "No, just change the parent"
    And I should see "Yes, create new combination"

    When I press "No, just change the parent"
    Then I should see "Atta speccus subbus"

  Scenario: Changing parent of subspecies to a species with an inconsistent name
    Given I log in as a superadmin
    And there is a subspecies "Batta fpeccus subbus" which is a subspecies of "Batta fpeccus" in the genus "Batta"
    And there is a subspecies "Atta speccus subbus" which is a subspecies of "Atta speccus" in the genus "Atta"

    When I go to the edit page for "Atta speccus subbus"
    Then I should see "subspecies of Atta speccus"

    When I click the parent name field
    And I set the parent name to "Batta fpeccus"
    And I press "OK"
    Then I should see "This new combination looks a lot like existing combinations."
    And I should see "Batta fpeccus subbus:"
    And I should see "This would become a secondary junior homonym; name conflict with distinct authorship"
    And I should see "Create secondary junior homonym of Batta fpeccus subbus: (Fisher"
    And I should see "No, just change the parent"
    And I should see "Yes, create new combination"

    When I press "No, just change the parent"
    Then I should see "Batta fpeccus:"
    And I should see "This does not match the name of the current species. Use with caution."
    And I should see "Yes, update parent record only"

    When I press "Yes, update parent record only"
    Then I should see "subspecies of Batta fpeccus"
