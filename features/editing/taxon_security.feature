@javascript
Feature: Security for editing taxa
  As an administrator of AntCat
  I want to limit the people who can update the site
  So that accidents don't occur
  And make AntCat less valuable

  Background:
    Given these references exist
      | authors | citation   | title | year | doi |
      | Fisher  | Psyche 3:3 | Ants  | 2004 |          |
    And there is a subfamily "Formicinae"

  @search
  Scenario: Adding a genus
    Given there is a genus "Eciton"
    When I go to the catalog page for "Formicinae"
    Then I should not see "Edit"
    When I log in through the web interface
    And I go to the catalog page for "Formicinae"
    And I press "Edit"
    And I press "Add genus"
    When I click the name field
      And I set the name to "Atta"
      And I press "OK"
    And I click the protonym name field
      And I set the protonym name to "Eciton"
      And I press "OK"
    And I click the authorship field
      And I search for the author "Fisher"
      And I click the first search result
      And I press "OK"
    And I click the type name field
      And I set the type name to "Atta major"
      And I press "OK"
      And I press "Add this name"
    And I save my changes
    Then I should be on the catalog page for "Atta"
