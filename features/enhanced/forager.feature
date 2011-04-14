Feature: Using the Forager
  As a user of AntCat
  I want to browse the ant catalog

  Background:
    Given a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "<p><b>Dolichoderinae</b></p>Dolichoderinae history"
      And a subfamily exists with a name of "Myrmicinae" and a taxonomic history of "<p><b>Myrmicinae</b></p>Myrmicinae history"
    When I go to the Forager

  Scenario: Viewing the index page
    Then I should see "Dolichoderinae" within "#index"
      And I should see "Myrmicinae" within "#index"
      And I should see "Dolichoderinae" within "#browser"
      And I should see "Dolichoderinae history" within "#browser"
      And I should see "Myrmicinae" within "#browser"
      And I should see "Myrmicinae history" within "#browser"

  Scenario: Clicking an index item
    Then I should see "Dolichoderinae history"
    When I follow "Myrmicinae" within "#index"
    Then I should not see "Dolichoderinae history"
