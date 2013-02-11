@javascript @editing
Feature: Taxt editor

  Scenario: Bringing up the reference picker
    When I go to the taxt editor test page
    And I fill in "taxt_edit_box" with "{"
    And I press "Reference"
    Then I should see the reference picker

  Scenario: Bringing up the name popup
    When I go to the taxt editor test page
    And I fill in "taxt_edit_box" with "{"
    And I press "Taxon"
    Then I should see the name popup
    And I should not see the reference picker

  Scenario: Cancelling while choosing the tag type
    When I go to the taxt editor test page
    And I fill in "taxt_edit_box" with "{"
    Then I should see "{Inserting...}"
    And I press "Cancel"
    Then I should not see "{Inserting...}"
