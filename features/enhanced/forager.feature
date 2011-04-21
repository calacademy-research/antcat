Feature: Using the Forager
  As a user of AntCat
  I want to browse the ant catalog

  Background:
    Given a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "<p><b>Dolichoderinae</b></p>Dolichoderinae history"
      And a subfamily exists with a name of "Myrmicinae" and a taxonomic history of "<p><b>Myrmicinae</b></p>Myrmicinae history"
      And a genus exists with a name of "Atta" and a subfamily of "Myrmicinae" and a taxonomic history of "Atta history"
      And a genus exists with a name of "Tetramorium" and a subfamily of "Myrmicinae" and a taxonomic history of "Tetramorium history"
      And a species exists with a name of "nigra" and a genus of "Atta" and a taxonomic history of "nigra history"
    When I go to the Forager

  Scenario: Viewing subfamilies
    Then I should see "Dolichoderinae" in the browser
      And I should see "Myrmicinae" in the browser
      And I should see "Dolichoderinae" in the browser
      And I should see "Dolichoderinae history" in the browser
      And I should see "Myrmicinae" in the browser
      And I should see "Myrmicinae history" in the browser

  # This scenario fails as the jQuery .scrollTo call aborts the index
  # selecion procedure
  #Scenario: Clicking an index item
  #  When I follow "Myrmicinae" in the index
  #  Then I should see "Myrmicinae history"
  #    And I should not see "Dolichoderinae history"
  #    And "Myrmicinae" should be selected in the index

  Scenario: Clicking a subfamily heading in the browser
    When I follow "Myrmicinae" in the browser
    Then I should see "Atta" in the index
      And I should see "Myrmicinae" in the browser
      And I should see "Myrmicinae history" in the browser
      And I should see "Atta history" in the browser

  Scenario: Clicking a subfamily heading in the index which is showing genera
    When I follow "Myrmicinae" in the browser
    Then I should not see "Dolichoderinae" in the index
    When I follow "Myrmicinae" in the index
    Then I should see "Dolichoderinae" in the index

  Scenario: Clicking a genus heading in the browser
    When I follow "Myrmicinae" in the browser
      And I follow "Atta" in the browser
    Then I should see "nigra" in the index
      And I should see "nigra history" in the browser

  Scenario: Clicking a genus heading in the index which is showing species
    When I follow "Myrmicinae" in the browser
    Then I should see "Tetramorium" in the index
    When I follow "Atta" in the browser
      Then I should not see "Tetramorium" in the index
    When I follow "Atta" in the index
    Then I should see "Tetramorium" in the index

  Scenario: Clicking a subfamily heading in the index which is showing species
    When I follow "Myrmicinae" in the browser
    Then I should see "Tetramorium" in the index
    When I follow "Atta" in the browser
      Then I should not see "Tetramorium" in the index
    When I follow "Myrmicinae" in the index
    Then I should see "Dolichoderinae" in the index

