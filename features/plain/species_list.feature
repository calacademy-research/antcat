Feature: Species list
  As a researcher
  I want to see a list of all ant species
  So that I can see what names exist and don't exist
  For when I name my own species

  Scenario: View species list
    Given the following species exist
      |name                      |
      |Acanthognathus brevicornis|
    When I go to the species list
    Then I should see "Acanthognathus brevicornis"
