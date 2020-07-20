Feature: Editing a taxon
  Background:
    Given I log in as a catalog editor named "Archibald"

  @javascript
  Scenario: Changing the authorship
    Given there is a genus "Eciton"
    And there is a genus protonym "Formica" with pages and form 'page 9, dealate queen'

    When I go to the catalog page for "Eciton"
    Then I should not see "Formica"

    When I go to the edit page for "Eciton"
    And I pick "Formica" from the protonym selector
    Then I should see "Formica"

    When I press "Save"
    Then I should see "Formica" within "#protonym-synopsis"
    And I should see "page 9 (dealate queen)" within "#protonym-synopsis"

  @javascript
  Scenario: Changing current taxon
    Given there is a species "Atta major" which is a junior synonym of "Lasius niger"
    And there is a species "Eciton minor"

    When I go to the catalog page for "Atta major"
    Then I should see "synonym of current valid taxon Lasius niger"

    When I follow "Edit"
    And I set the current taxon name to "Eciton minor"
    Then I should see "Eciton minor"

    When I press "Save"
    Then I should see "synonym of current valid taxon Eciton minor"

  Scenario: Changing incertae sedis (with edit summary)
    Given there is a genus "Atta"

    When  I go to the catalog page for "Atta"
    Then I should not see "incertae sedis in subfamily"

    When I go to the edit page for "Atta"
    And I select "Subfamily" from "taxon_incertae_sedis_in"
    And I fill in "edit_summary" with "fix incertae sedis"
    And I press "Save"
    Then I should be on the catalog page for "Atta"
    And I should see "incertae sedis in subfamily"

    When I go to the activity feed
    Then I should see "Archibald edited the genus Atta" within the activity feed
    And I should see the edit summary "fix incertae sedis"

  Scenario: Changing gender of genus-group name
    Given there is a genus "Atta"

    When I go to the catalog page for "Atta"
    Then I should not see "masculine"

    When I go to the edit page for "Atta"
    And I select "masculine" from "taxon_name_attributes_gender"
    And I press "Save"
    Then I should be on the catalog page for "Atta"
    And I should see "masculine"
