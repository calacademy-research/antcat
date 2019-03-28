Feature: Manage protonyms
  Background:
    Given I am logged in as a helper editor

  Scenario: Editing a protonym
    Given there is a genus protonym "Formica" with pages and form 'page 9, dealate queen'

    When I go to the protonyms page
    And I follow "Formica"
    Then I should see "page 9"
    And I should see "dealate queen"

    When I follow "Edit"
    And I fill in "protonym_authorship_attributes_pages" with "page 35"
    And I fill in "protonym_authorship_attributes_forms" with "male"
    And I press "Save"
    Then I should see "Protonym was successfully updated"
    And I should see "page 35"
    And I should see "male"
