@javascript @editing
Feature: Taxt edit box

  Scenario: Cancelling while choosing the tag type
    When I go to the taxt editor test page
    And I fill in "taxt_edit_box" with "{"
    Then I should see "{Insert...}"
    And I press "Cancel"
    Then I should not see "{Insert...}"
