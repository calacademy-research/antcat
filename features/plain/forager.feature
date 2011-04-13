Feature: Using the Forager
  As a user of AntCat
  I want to browse the ant catalog

  Background:
    Given a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "<p><b>Dolichoderinae</b></p>A sweet little subfamily"
      And a subfamily exists with a name of "Myrmiciniae" and a taxonomic history of "<p><b>Myrmiciniae</b></p>Myrmicinae history"
    When I go to the Forager

  Scenario: Viewing the index page
    Then I should see "Dolichoderinae"
      And I should see "A sweet little subfamily"
      And I should see "Myrmicinae"
      And I should see "Myrmicinae history"
