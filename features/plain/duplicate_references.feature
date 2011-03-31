Feature: View duplicate references
  As a programmer
  I want to see a list of all potentially duplicate references
  So that I can prune them

  Scenario: View duplicate references
    Given the following references exist in the bibliography
      |author     |title|year|citation  |
      |Ward, P. S.|Ants |1960|Psyche 1:2|
      |Bolton, B. |Bees |1958|Psyche 2:3|
      |Ward, P. S.|Cows |1961|Psyche 4:5|
      And the following are duplicates
        |authors    |year|similarity|
        |Ward, P. S.|1960|          |
        |Ward, P. S.|1961|1.0       |
    When I go to the duplicate reference list
    Then I should see one target reference
      And I should see one duplicate reference
      And I should see the target reference "Ward, P. S. 1960"
      And I should see the possible duplicate for it "Ward, P. S. 1961" with similarity "1.0"
      And I should not see "Bolton, B. 1958"
