Feature: Edit reference unsuccessfully
  Background:
    Given I am logged in as a catalog editor

  Scenario: Cancelling edit after an error
    Given this reference exists
      | author    | citation_year | title                    | citation      |
      | Forel, A. | 1874          | Les fourmis de la Suisse | Neue 26:1-452 |

    When I go to the edit page for the most recent reference
    And I fill in "reference_title" with ""
    And I press "Save"
    Then I should see "Title can't be blank"

    When I follow "Cancel"
    Then I should see "Forel, A. 1874. Les fourmis de la Suisse. Neue 26:1-452"
