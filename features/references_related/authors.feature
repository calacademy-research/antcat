Feature: Working with authors and their names
  Scenario: Seeing all the authors with their names
    Given the following names exist for an author
      | Bolton, B. |
      | Bolton,B.  |
    And the following names exist for another author
      | Fisher, B. |

    When I go to the authors page
    Then I should see "Bolton, B.; Bolton,B."
    And I should see "Fisher, B."

  Scenario: Attempting to access edit page without being logged in
    Given the following names exist for an author
      | Bolton, B. |

    When I go to the author edit page for "Bolton, B."
    Then I should be on the login page

  @javascript
  Scenario: Adding an alternative spelling of an author name
    Given the following names exist for an author
      | Bolton, B. |
    And I am logged in

    When I go to the author edit page for "Bolton, B."
    And I press "Add alternative spelling"
    And I fill in "author_name" with "Fisher, B."
    And I press "Save"
    And I wait for a bit
    And I follow "Authors" inside the breadcrumb
    Then I should see "Bolton, B.; Fisher, B."

  @javascript
  Scenario: Entering an existing author name
    Given the following names exist for an author
      | Bolton, B. |
    And I am logged in

    When I go to the author edit page for "Bolton, B."
    And I press "Add alternative spelling"
    And I fill in "author_name" with "Bolton, B."
    And I press "Save"
    Then I should see "Name has already been taken"

  @javascript
  Scenario: Updating an existing author name
    Given the following names exist for an author
      | Bolton, B. |
    And I am logged in

    When I go to the author edit page for "Bolton, B."
    And I click ".author_name > .display"
    And I fill in "author_name" with "Bolton, Z."
    And I press "Save"
    And I wait for a bit
    And I follow "Authors" inside the breadcrumb
    Then I should see "Bolton, Z."
    And I should not see "Bolton, B."

  Scenario: Seeing references by author
    Given this book reference exist
      | authors    | year | title     | citation                |
      | Bolton, B. | 2010 | Cool Ants | New York: Wiley, 23 pp. |

    When I go to the authors page
    And I follow "Bolton, B."
    Then I should see "Cool Ants"
