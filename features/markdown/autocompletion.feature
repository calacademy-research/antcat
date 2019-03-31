@javascript
Feature: Markdown autocompletion
  Background:
    Given I log in as a catalog editor named "Archibald"

  @search
  Scenario: References markdown autocompletion
    Given there is a Giovanni reference
    And there is a reference by Giovanni's brother
    And I am on a page with a textarea with markdown preview and autocompletion

    When I fill in "issue_description" with "{rgio"
    Then I should see "Giovanni's Favorite Ants"
    And I should see "Giovanni's Brother's Favorite Ants"

    When I clear the markdown textarea
    Then I should not see "Favorite Ants"

    When I fill in "issue_description" with "{rbro"
    And I click the suggestion containing "Giovanni's Brother's Favorite Ants"
    Then the markdown textarea should contain "{ref 7778}"

  @search
  Scenario: Recently used references (added by inserting in a markdown textarea)
    Given RESET SESSION
    And these references exist
      | author | title         | citation_year |
      | Fisher | Fisher's Ants | 2004          |
      | Forel  | Forel's Ants  | 1910          |
      | Bolton | Bolton's Ants | 2003          |

    When I am on a page with a textarea with markdown preview and autocompletion
    And I fill in "issue_description" with "{rfish"
    And I click the suggestion containing "Fisher's Ants"
    And WAIT

    When I am on a page with a textarea with markdown preview and autocompletion
    Then I should not see "Fisher's Ants"
    And I should not see "Forel's Ants"
    And I should not see "Bolton's Ants"

    When I fill in "issue_description" with "!!"
    Then I should see "Fisher's Ants"
    And I should not see "Forel's Ants"
    And I should not see "Bolton's Ants"

  Scenario: Recently used references (added from reference page)
    Given RESET SESSION
    And these references exist
      | author | title         | citation_year |
      | Fisher | Fisher's Ants | 2004          |
      | Forel  | Forel's Ants  | 1910          |
      | Bolton | Bolton's Ants | 2003          |

    When I go to the page of the reference "Bolton, 2003"
    And I click the Add to Recently Used button
    Then I should see "Added to recently used references"

    When I am on a page with a textarea with markdown preview and autocompletion
    Then I should not see "Fisher's Ants"
    And I should not see "Forel's Ants"
    And I should not see "Bolton's Ants"

    When I fill in "issue_description" with "!!"
    Then I should see "Bolton's Ants"
    Then I should not see "Fisher's Ants"
    And I should not see "Forel's Ants"

  Scenario: Taxa markdown autocompletion
    Given there is a genus "Eciton"
    And there is a genus "Atta"
    And I am on a page with a textarea with markdown preview and autocompletion

    When I fill in "issue_description" with "{tec"
    Then I should see "Eciton"

    When I click the suggestion containing "Eciton"
    Then the markdown textarea should contain a markdown link to Eciton

  Scenario: User markdown autocompletion
    Given I am on a page with a textarea with markdown preview and autocompletion

    When I fill in "issue_description" with "@arch"
    And I click the suggestion containing "Archibald"
    Then the markdown textarea should contain a markdown link to Archibald's user page

  # Testing multiple at the same time because JS tests are painfully slow.
  Scenario: Journal, issue and feedback markdown autocompletion
    Given a journal exists with a name of "Ant Science 2000"
    And there is a closed issue "Cleanup synonyms"
    And a visitor has submitted a feedback
    And I am on a page with a textarea with markdown preview and autocompletion

    # Issue
    When I fill in "issue_description" with "%icle"
    And I click the suggestion containing "Cleanup"
    Then the markdown textarea should contain "%issue"

    # Feedback
    When I fill in "issue_description" with "%f"
    And I click the suggestion containing "open"
    Then the markdown textarea should contain "%feedback"
