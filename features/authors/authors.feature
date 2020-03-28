Feature: Working with authors and their names
  Scenario: Seeing references by author (going to the author's page)
    Given this reference exists
      | author     | title     |
      | Bolton, B. | Cool Ants |

    When I go to the page of the most recent reference
    And I follow the first "Bolton, B."
    Then I should see "References by Bolton, B."
    And I should see "Cool Ants"

  Scenario: Seeing all the authors with their names
    Given the following names exist for an author
      | Bolton, B. |
      | Bolton,B.  |
    And the following names exist for another author
      | Fisher, B. |

    When I go to the authors page
    Then I should see "Bolton, B.; Bolton,B."
    And I should see "Fisher, B."

  Scenario: Adding an alternative spelling of an author name
    Given the following names exist for an author
      | Bolton, B. |
    And I log in as a catalog editor

    When I go to the author page for "Bolton, B."
    And I follow "Add alternative spelling"
    And I fill in "author_name_name" with "Fisher, B."
    And I press "Save"
    And I wait
    And I follow "Authors" within the breadcrumbs
    Then I should see "Bolton, B.; Fisher, B."

  Scenario: Entering an existing author name
    Given the following names exist for an author
      | Bolton, B. |
    And I log in as a catalog editor

    When I go to the author page for "Bolton, B."
    And I follow "Add alternative spelling"
    And I fill in "author_name_name" with "Bolton, B."
    And I press "Save"
    Then I should see "Name has already been taken"

  Scenario: Updating an existing author name
    Given the following names exist for an author
      | Bolton, B. |
    And I log in as a catalog editor

    When I go to the author page for "Bolton, B."
    And I follow "Edit"
    And I fill in "author_name_name" with "Bolton, Z."
    And I press "Save"
    And I wait
    And I follow "Authors" within the breadcrumbs
    Then I should see "Bolton, Z."
    And I should not see "Bolton, B."
