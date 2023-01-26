Feature: Merging authors
  As an editor of AntCat
  I want to merge together author names
  So that they are correct

  Background:
    Given I log in as a catalog editor
    And these references exist
      | author      | title          |
      | Bolton, B.  | Annals of Ants |
      | Bolton, Ba. | More ants      |

  Scenario: Merging two authors
    When I go to the author page for "Bolton, B."
    Then I should see "Bolton, B."
    And I should not see "Bolton, Ba."

    When I follow "Merge"
    And I set author_to_merge_id to the ID of "Bolton, Ba."
    And I press "Next"
    Then I should see "Annals of Ants"
    And I should see "More ants"

    When I press "Merge these authors"
    Then I should see "Probably merged authors"
    And I should be on the author page for "Bolton, B."
    And I should see "Bolton, Ba."
    And I should see "Bolton, B."

  Scenario: Searching for an author that isn't found
    When I go to the author page for "Bolton, B."
    And I follow "Merge"
    And I fill in "author_to_merge_name" with "asdf"
    And I press "Next"
    Then I should see "Author to merge must be specified"
