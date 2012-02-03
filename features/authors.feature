Feature: Editing authors and author names
  As an editor of AntCat
  I want to edit/add/assign authors to names and vice versa
  So that they are correct

  Background:
    Given the following names exist for an author
      |name      |
      |Bolton, B.|
      |Bolton,B. |
    And the following references exist
      |authors   |title         |year|citation  |
      |Bolton, B.|Annals of Ants|2010|Psyche 1:1|
      |Bolton,B. |More ants     |2011|Psyche 2:2|

  Scenario: Not logged in
    When I go to the references page
    Then I should see "Authors"

  Scenario: Logged in
    Given I am logged in
    When I go to the references page
      And I follow "Authors"
    Then I should be on the "Authors" page

  Scenario: Searching for an author
    Given I am logged in
    When I go to the "Authors" page
    Then I should not see "Bolton, B." in an author panel
    When I fill in the search box with "Bolton, B."
      And I press "Go" by the search box
    Then I should see "Bolton, B." in an author panel
      And I should see "Bolton,B." in an author panel
      And I should see "Annals of Ants" in an author panel
      And I should see "More ants" in an author panel

  Scenario: Searching for an author that isn't found
    Given I am logged in
    When I go to the "Authors" page
    When I fill in the search box with "asdfsadf"
      And I press "Go" by the search box
    Then I should see "No results found" in an author panel
