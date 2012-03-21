@javascript
Feature: Reference picker

  Scenario: Seeing the picker
    Given the following references exist
      | authors    | year  | title     | citation | cite_code | possess | date     | public_notes | editor_notes   |
      | Ward, P.S. | 2010d | Ant Facts | Ants 1:1 | 232       | PSW     | 20100712 | Public notes | Editor's notes |
    When I go to the reference picker widget test page
    Then I should see "Ward, P.S. 2010d. Ant Facts. Ants 1:1. [2010-07-12]"
    And I should see "Public notes"
    And I should not see "Editor's notes"
