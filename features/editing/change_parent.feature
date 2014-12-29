@javascript
Feature: Changing parent genus, species, tribe or subfamily
  As an editor of AntCat
  I want to change a taxon's parent
  So that information is kept accurate
  So people use AntCat

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
    Then the name field should contain "Eciton major"
    When I save my changes
    Then I should be on the catalog page for "Eciton major"
    And the name in the header should be "Eciton major"
    When I go to the catalog page for "Atta major"
    Then I should see "see Eciton major"

  # Change parent from A -> B -> A
  # Joe todo: This case set is incomplete. Currenly defaults to creating the homonym
  Scenario: Creating a secondary junior homonym
    Given there is species "Atta major" and another species "Beta major" shared between protonym genus "Atta" and later genus "Beta"
    When I go to the edit page for "Beta major"
    And I click the parent name field
    And I set the parent name to "Atta"
    And I press "OK"
    Then I should see "This new combination looks a lot like existing combinations"
    When I press "Yes, create new combination"
#    When I submit the new species form
    #When I save my changes
#    Then I should see an alert box
#    Then I should see ""



    #test case notes:

  # try this for a case where there are no duplicate candidates
  # try this for a case with more than one duplicate candidate
  # duplicate candidate, choose one  (for each of the above)
  # duplicate candidate, make a homonym
  # For homonym case, check that the references for "b" in a - b -a' case are good.
  # for reversion case(s), check that the references for "b" are good
  # for a case where there is one or more duplicatre candidates, hit cancel on dialog box (throbber case!)
  # Standard case(maybe already covered?) where there is no conflict/duplicate
  # a-b-a' case for both options     (with and without approval)
  # a-b-c case, check all references
  # a-b-c + appprove, check all reference


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
    Then the name field should contain "Chatsworth major"
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
