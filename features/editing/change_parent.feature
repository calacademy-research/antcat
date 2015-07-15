@javascript
Feature: Changing parent genus, species, tribe or subfamily
  As an editor of AntCat
  I want to change a taxon's parent
  So that information is kept accurate
  So people use AntCat

  Background:
    Given I am logged in
    And that version tracking is enabled

  Scenario: Changing a species's genus
    Given there is a genus "Atta"
    And there is a genus "Eciton"
    And there is a species "Atta major" with genus "Atta"
    When I go to the edit page for "Atta major"
    And I click the parent name field
    And I set the parent name to "Eciton"
    And I press "OK"
    And I should see "Would you like to create a new combination under this parent?"
    When I save my changes
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
    When I save my changes
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
    When I save my changes



    # not working. Cancel never seems to get hit. Likely a webdriver problem.
#  Scenario: I cancel out of the homonym conflict box
#    Given there is species "Atta major" and another species "Beta major" shared between protonym genus "Atta" and later genus "Beta"
#    When I go to the edit page for "Beta major"
#    And I click the parent name field
#    And I set the parent name to "Atta"
#    And I press "OK"
#    Then I should see "This new combination looks a lot like existing combinations"
#    And I should see "Choose a representation"
#    And I should see "Atta major: (Fisher5, 2015) return to a previous usage"
#    And I should see "Create secondary junior homonym of Atta major"
#    When I press "Cancel-Dialog"
#    Then I should not see "Atta"
#    Broken. "cancel" button is found, but the button press isn't going through.

#    Then The parent name field should have "Beta"
#    When I click the parent name field
#    And I set the parent name to "Atta"
#    Then I should see "This new combination looks a lot like existing combinations"


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
    When I press "Yes, create new combination"
    Then I should see "new secondary junior homonym of species of Atta"

  Scenario: Merging when we have distinct protonyms
    Given there is a species "Atta major" with genus "Atta"
    Given there is a species "Beta major" with genus "Beta"
    When I go to the edit page for "Beta major"
    And I click the parent name field
    And I set the parent name to "Atta"
    And I press "OK"
    Then I should see "This new combination looks a lot like existing combinations"
    And I should see "Choose a representation"
    And I should not see "Atta major: (Fisher5, 2015) return to a previous usage"
    And I should see "This would become a secondary junior homonym; name conflict with distinct authorship"
    When I choose "homonym"
    When I press "Yes, create new combination"
    Then I should see "new secondary junior homonym of species of Atta"



    #test case notes:

  # try this for a case where there are no duplicate candidates
  # try this for a case with more than one duplicate candidate
  # For homonym case, check that the references for "b" in a - b -a' case are good.
  # for reversion case(s), check that the references for "b" are good
  # Standard case(maybe already covered?) where there is no conflict/duplicate
  # a-b-a' case for both options     (with and without approval)
  # a-b-c case, check all references
  # a-b-c + appprove, check all reference
  Scenario: Detecting a possible secondary homonym when there is a subspecies name conflict
    Given there is a subspecies "Solenopsis speccus subbus" which is a subspecies of "Solenopsis speccus" in the genus "Solenopsis"
    Given there is a subspecies "Atta betus subbus" which is a subspecies of "Atta betus" in the genus "Atta"
    And I am logged in
    When I go to the edit page for "Solenopsis speccus subbus"
    And I click the parent name field
    And I set the parent name to "Atta betus"
    And I press "OK"
    Then I should see "This new combination looks a lot like existing combinations"
    And I should see "Atta betus subbus"
    And I should see "This would become a secondary junior homonym; name conflict with distinct authorship"
    Then I choose "secondary_junior_homonym"
    And I press "Yes, create new combination"
    Then I should see "new secondary junior homonym of subspecies of Atta betus"
    When I save my changes
    Then I should see "Atta betus subbus"
    And I should see "unresolved junior homonym"
    And I should see "This taxon has been changed; changes awaiting approval"



  # tagged "work in progress" - I saw this fail once, requires checking.
#  Scenario: Change a subspecies to a species should error gracefully
#    Given there is a subspecies "Solenopsis speccus subbus" which is a subspecies of "Solenopsis speccus" in the genus "Solenopsis"
#    Given there is a genus "Atta"
#    And I am logged in
#    When I go to the edit page for "Solenopsis speccus subbus"
#    And I click the parent name field
#    And I set the parent name to "Atta"
#    And I press "OK"
#    Try this manually, see what happens. If all is well, then that's bad - this should be an error case.

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
    When I save my changes

    # Change parent from B -> C
    When I go to the edit page for "Becton major"
    And I click the parent name field
    And I set the parent name to "Chatsworth"
    And I press "OK"
    Then I should see "Would you like to create a new combination under this parent?"
    When I press "Yes, create new combination"
    Then the name button should contain "Chatsworth major"
    When I save my changes

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
    When I save my changes
    And I should see "This name is in use by another taxon"

  Scenario: Changing a subspecies's species
    Given there is a species "Atta major" with genus "Atta"
    And there is a species "Eciton nigra" with genus "Eciton"
    And there is a subspecies "Atta major minor" which is a subspecies of "Atta major"
    When I go to the edit page for "Atta major minor"
    And I click the parent name field
    And I set the parent name to "Eciton nigra"
    And I press "OK"
    When I save my changes
    Then I should be on the catalog page for "Eciton nigra minor"
    And the name in the header should be "Eciton nigra minor"

  Scenario: Parent field not visible for the family
    Given there is a family "Formicidae"
    When I go to the edit page for "Formicidae"
    Then I should not see the parent name field

  Scenario: Parent field not visible while adding
    Given there is a species "Eciton major" with genus "Eciton"
    When I go to the catalog page for "Eciton major"
    And I press "Edit"
    And I press "Add subspecies"
    And I wait for a bit
    Then I should be on the new taxon page
    Then I should not see the parent name field

  Scenario: Fixing a subspecies without a species
    Given there is a species "Crematogaster menilekii"
    And there is a subspecies "Crematogaster menilekii proserpina" without a species
    When I go to the edit page for "Crematogaster menilekii proserpina"
    And I click the parent name field
    And I set the parent name to "Crematogaster menilekii"
    And I press "OK"
    When I save my changes
    Then I should be on the catalog page for "Crematogaster menilekii proserpina"

  Scenario: Changing a genus's tribe
    Given there is a tribe "Attini"
    And genus "Atta" exists in that tribe
    And there is a tribe "Ecitoni"
    When I go to the edit page for "Atta"
    And I click the parent name field
    And I set the parent name to "Ecitoni"
    And I press "OK"
    When I save my changes
    Then I should be on the catalog page for "Atta"
    When I follow "show tribes"
    And "Ecitoni" should be selected in the tribes index

  Scenario: Changing a genus's subfamily
    Given there is a subfamily "Attininae"
    And genus "Atta" exists in that subfamily
    And there is a subfamily "Ecitoninae"
    When I go to the edit page for "Atta"
    And I click the parent name field
    And I set the parent name to "Ecitoninae"
    And I press "OK"
    When I save my changes
    Then I should be on the catalog page for "Atta"
    And "Ecitoninae" should be selected in the subfamilies index

  Scenario: Setting a genus's parent to blank
    Given there is a subfamily "Attininae"
    And genus "Atta" exists in that subfamily
    When I go to the edit page for "Atta"
    And I click the parent name field
    And I set the parent name to ""
    And I press "OK"
    When I save my changes
    Then I should be on the catalog page for "Atta"
    And "(no subfamily)" should be selected in the subfamilies index

  Scenario: Setting a genus's parent to a nonexistent name
    Given there is a subfamily "Attininae"
    And genus "Atta" exists in that subfamily
    When I go to the edit page for "Atta"
    And I click the parent name field
    And I set the parent name to "Appaloosa"
    And I press "OK"
    Then I should see "This must be the name of an existing taxon"

    joe's new cases
    # All are to fix the missing "species_id" for a subspecies
    # Pick a name that has no duplicates. It should have simple dialogs and then warp to a page that has the fix.
    # Pick a name that has duplicates. Force a choice.
    # Pick a name that doesn't match the current name (foo bar baz vs. with a parent of foo splat). Choices should have warnings.
    # Changing a subspecies parent when species_id is current set should do the right thing, whatever that is.
    # Attempt to save a subspecies with a genus parent - should alert.  # not done
    # attempt to save a species with a family parent - should alert.    # not done
    # attempt to save any taxon with no parent - should alert           # not done
    # Attempt to change to a parent with a name match but no associated taxon records (it can happen!) should show abort/fail message.
