Feature: Citations
  Scenario: Showing citations used on a catalog page
    Given there is a genus Lasius described in Systema Piezatorum

    When I go to the catalog page for "Lasius"
    Then I should see "Systema Piezatorum" within the citations section
