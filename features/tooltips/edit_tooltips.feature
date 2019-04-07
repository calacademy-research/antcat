Feature: Editing tooltips
  As an editor of AntCat
  I want to add and edit tooltips
  So that other editors can understand how to edit the catalog

  Background:
    Given I am logged in as a helper editor

  @javascript
  Scenario: Hovering a tooltip
    When I go to the references page
    And I follow "New"
    And I hover the tooltip next to the text "Authors"
    Then I should not see the tooltip text "Separate author names by semicolons"

    When I go to the tooltips editing page
    And I follow "New Tooltip"
      And I fill in "tooltip[key]" with "authors"
      And I fill in "tooltip[scope]" with "references"
      And I fill in "tooltip[text]" with "Separate author names by semicolons"
    And I press "Create Tooltip"
    Then I should see "Tooltip was successfully created."

    When I go to the references page
    And I follow "New"
    And I hover the tooltip next to the text "Authors"
    Then I should see the tooltip text "Separate author names by semicolons"
