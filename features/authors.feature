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
    And the following names exist for another author
      |name      |
      |Fisher, B.|

  Scenario: Searching for an author
    When I go to the "Authors" page
    Then I should not see "Bolton, B." in the author panel
    When I fill in the search box in the author panel with "Bolton, B."
      And I press "Go" in the author panel
    Then I should see "Bolton, B." in the author panel
      And I should see "Bolton,B." in the author panel
      And I should see "Annals of Ants" in the author panel
      And I should see "More ants" in the author panel

  Scenario: Searching for an author that isn't found
    When I go to the "Authors" page
    When I fill in the search box in the author panel with "asdf"
      And I press "Go" in the author panel
    Then I should see "No results found" in the author panel

  Scenario: Opening more than one search panel
    When I go to the "Authors" page
    When I fill in the search box in the author panel with "Bolton, B."
      And I press "Go" in the author panel
    Then I should see "Bolton, B." in the author panel
    When I fill in the search box in the last author panel with "Fisher, B."
      And I press "Go" in the last author panel
    Then I should see "Fisher, B." in the last author panel
      And I should see "Bolton, B." in the first author panel

