@javascript
Feature: Editing a taxon
  As an editor of AntCat
  I want to edit taxa
  So that information is kept accurate
  So people use AntCat

  Scenario: Trying to edit without being logged in
    Given there is a genus "Calyptites"
    When I go to the edit page for "Calyptites"
    And I should be on the login page

  Scenario: Trying to edit without catalog editing rights
    Given there is a genus "Calyptites"
    And I log in as a bibliography editor
    When I go to the catalog page for "Calyptites"
    Then I should not see "Edit"

  @preview
  Scenario: Trying to edit without catalog editing rights on preview server
    Given there is a genus "Calyptites"
    When I go to the catalog page for "Calyptites"
    And I press "Edit"
    Then I should be on the edit page for "Calyptites"

  # Don't allow changing the name for now
  #Scenario: Editing a family's name
    #Given there is a family "Formicidae"
    #And I log in
    #When I go to the edit page for "Formicidae"
    #And I set the name to "Formica"
    #And I save the form
    #Then I should see "Formica" in the header

  Scenario: Editing a species
    Given a species exists with a name of "major" and a genus of "Atta"
    And I log in
    When I go to the catalog page for "Atta major"
    Then I should see "Atta major" in the header
    When I go to the edit page for "Atta major"
    And I save the form
    And I wait for a bit
    Then I should see "Atta major" in the header

  #Scenario: Trying to enter a blank name
    #Given there is a genus "Calyptites"
    #And I log in
    #When I go to the edit page for "Calyptites"
    #And I set the name to ""
    #And I save the form
    #Then I should see "Name can't be blank"

  #Scenario: Setting a genus's name to an existing one
    #Given there is a genus "Calyptites"
    #And there is a genus "Atta"
    #And I log in
    #When I go to the edit page for "Atta"
    #And I set the name to "Calyptites"
    #And I save the form
    #Then I should see "This name is in use by another taxon"
    #When I press "Save Homonym"
    #Then there should be two genera with the name "Calyptites"

  #Scenario: Leaving a genus name alone when there are already two homonyms
    #Given there are two genera called "Calyptites"
    #And I log in
    #When I go to the edit page for "Calyptites"
    #And I save the form
    #Then I should not see "This name is in use by another taxon"
    #Then I should see "Calyptites" in the header

  # These scenarios both bring up the name popup when Insert Name
  # is clicked, but also submits the form
  #Scenario: Changing taxt
    #Given there is a genus "Atta"
    #And there is a genus "Eciton"
    #And I log in
    #When I go to the catalog page for "Atta"
    #Then I should not see "Eciton"
    #When I press "Edit"
    #And I put the cursor in the headline notes edit box
    #And I press "Insert Name"
    #Then I should not be on the catalog page for "Atta"
    #And I fill in the name with "Eciton"
    #And I press "OK"
    #Then I should not be on the catalog page for "Atta"

  #Scenario: Changing reference in taxt
    #Given there is a genus "Atta"
    #And there is a genus "Eciton"
    #And I log in
    #When I go to the catalog page for "Atta"
    #And I press "Edit"
    #And I put the cursor in the headline notes edit box
    #And I press "Insert Reference"
    #And I press "OK"
    #Then I should not be on the catalog page for "Atta"

  Scenario: Cancelling
    Given there is a genus "Calyptites"
    And I log in
    When I go to the edit page for "Calyptites"
    And I select "subfamily" from "taxon_incertae_sedis_in"
    And I press "Cancel"
    Then I should not see "incertae sedis" in the header

  Scenario: Changing the protonym name
    Given there is a genus "Atta" with protonym name "Atta"
    And there is a genus "Eciton"
    And I log in
    When I go to the edit page for "Atta"
    And I click the protonym name field
    And I set the protonym name to "Eciton"
    And I press "OK"
    And I save the form
    Then I should see "Eciton" in the headline

  Scenario: Changing the authorship
    Given these references exist
      | authors | citation   | title | year |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |
    Given there is a genus "Eciton"
    And I log in
    When I go to the edit page for "Eciton"
    And I click the authorship field
    And I search for the author "Fisher"
    And I click the first search result
    And I press "OK"
    Then the authorship field should contain "Fisher 2004. Ants. Psyche 3:3."
    When I save the form
    Then I should see "Fisher 2004. Ants. Psyche 3:3." in the headline

  Scenario: Changing the type name
    Given there is a genus "Atta" with type name "Atta major"
    And there is a species called "Atta major"
    And I log in
    When I go to the edit page for "Atta"
    And I click the type name field
    And I set the type name to "Atta major"
    And I press "OK"
    And I save the form
    Then I should see "Atta major" in the headline

  Scenario: Changing incertae sedis
    Given there is a genus "Atta" that is incertae sedis in the subfamily
    When I log in
    And I go to the catalog page for "Atta"
    Then I should see "incertae sedis in subfamily"
    When I go to the edit page for "Atta"
    And I select "(none)" from "taxon_incertae_sedis_in"
    And I save the form
    Then I should be on the catalog page for "Atta"
    Then I should not see "incertae sedis in subfamily"
