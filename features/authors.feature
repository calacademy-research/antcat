Feature: Editing authors and author names
  As an editor of AntCat
  I want to edit/add/assign authors to names and vice versa
  So that they are correct

  Background:
    Given the following names exist for an author
      |name      |
      |Bolton, B.|

  Scenario: Not logged in
    When I go to the references page
    Then I should not see "Authors"

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
