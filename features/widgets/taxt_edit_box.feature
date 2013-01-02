@javascript @editing
Feature: Taxt edit box

  Scenario: Bringing up the reference picker
    When I go to the taxt editor test page
    And I fill in "taxt_edit_box" with "{"
    And I press "Reference"
    Then I should see the reference picker

  # Will fix
  #Scenario: Bringing up the name picker
    #When I go to the taxt editor test page
    #And I fill in "taxt_edit_box" with "{"
    #And I press "Name"
    #Then I should see the name picker
    #And I should not see the reference picker

  Scenario: Cancelling while choosing the tag type
    When I go to the taxt editor test page
    And I fill in "taxt_edit_box" with "{"
    Then I should see "{Inserting...}"
    And I press "Cancel"
    Then I should not see "{Inserting...}"
