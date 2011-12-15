Feature: Importing from Bolton, then displaying it
  As the developer of AntCat
  I want to make Bolton's Word documents viewable on the Web
  So that it's more current and easier to search than now

  Scenario: Importing the family
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
    Then I should see the following text:
      |text|
      |Formicidae|
      |Formicariae|
