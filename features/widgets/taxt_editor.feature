@javascript @editing
Feature: Taxt editor

  Scenario: Bringing up the reference popup
    When I go to the taxt editor test page
    And I fill in "taxt_edit_box" with "{"
    And I press "Reference"
    Then I should see the reference popup

  Scenario: Bringing up the name popup
    When I go to the taxt editor test page
    And I fill in "taxt_edit_box" with "{"
    And I press "Taxon"
    Then I should see the name popup
    And I should not see the reference popup

  Scenario: Cancelling while choosing the tag type
    When I go to the taxt editor test page
    And I fill in "taxt_edit_box" with "{"
    Then I should see "{Inserting...}"
    And I press "Cancel" in the tag type selector
    Then I should not see "{Inserting...}"
