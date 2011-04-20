Feature: Using the Forager
  As a user of AntCat
  I want to browse the ant catalog

  Background:
    Given a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "<p><b>Dolichoderinae</b></p>Dolichoderinae history"
      And a subfamily exists with a name of "Myrmicinae" and a taxonomic history of "<p><b>Myrmicinae</b></p>Myrmicinae history"
      And a genus exists with a name of "Atta" and a subfamily of "Myrmicinae" and a taxonomic history of "Atta history"
    When I go to the Forager

  Scenario: Viewing subfamilies
    Then I should see "Dolichoderinae" within the browser
      And I should see "Myrmicinae" within the browser
      And I should see "Dolichoderinae" within the browser
      And I should see "Dolichoderinae history" within the browser
      And I should see "Myrmicinae" within the browser
      And I should see "Myrmicinae history" within the browser

  # This scenario fails as the jQuery .scrollTo call aborts the index
  # selecion procedure
  #Scenario: Clicking an index item
  #  When I follow "Myrmicinae" within the index
  #  Then I should see "Myrmicinae history"
  #    And I should not see "Dolichoderinae history"
  #    And "Myrmicinae" should be selected within the index

  Scenario: Clicking a browser heading
    When I follow "Myrmicinae" within the browser
    Then I should see "Atta" within the index
      And I should see "Atta history" within the browser
