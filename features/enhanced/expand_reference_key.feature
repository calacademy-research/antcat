Feature: Expanding reference keys
  As an AntCat user
  When I see a short reference key
  I want to be able to click it and see the full reference
  So that I don't have to switch context to see the information I need

  Scenario: Expanding a reference key in the catalog
    Given there is a reference for "Latreille, 1809"
      And the family import file contains the following lines:
      |line|
      |<p><b>FAMILY FORMICIDAE</b></p>|
      |<p><b>Family <span style='color:red'>FORMICIDAE</span></b></p>|
      |<p><b>Formicariae</b> Latreille, 1809: 124. Type-genus: <i>Formica</i>.</p>|
      |<p><b>Taxonomic history</b></p>|
      |<p>Formicidae as family: Latreille, 1809: 124 [Formicariae]; all subsequent authors.</p>|
    When I import the family file
    And I go to the catalog index
    Then I should see "Latreille, 1809"
      And I should not see "Latreille, I. 1809"
    When I follow "Latreille, 1809"
    Then I should see "Latreille, I. 1809"
      And I should not see "Latreille, 1809"
    When I follow the expansion
    Then I should see "Latreille, 1809"
      And I should not see "Latreille, I. 1809"
