Feature: Using the Taxatry browser
  As a user of AntCat
  I want to browse the ant catalog

  Background:
    Given a subfamily exists with a name of "Dolichoderinae" and a taxonomic history of "<p><b>Dolichoderinae</b></p>Dolichoderinae history"
      And a subfamily exists with a name of "Myrmicinae" and a taxonomic history of "<p><b>Myrmicinae</b></p>Myrmicinae history"
      And a genus exists with a name of "Atta" and a subfamily of "Myrmicinae" and a taxonomic history of "Atta history"
      And a genus exists with a name of "Tetramorium" and a subfamily of "Myrmicinae" and a taxonomic history of "Tetramorium history"
      And a genus exists with a name of "Myrmicinae" and a taxonomic history of "Myrmicinae history"
      And a species exists with a name of "nigra" and a genus of "Atta" and a taxonomic history of "Atta nigra history"
      And a species exists with a name of "attaxus" and a genus of "Tetramorium" and a taxonomic history of "Tetramorium attaxus history"
      And a species exists with a name of "nigra" and a genus of "Tetramorium" and a taxonomic history of "Tetramorium nigra history"
    When I go to the Taxatry browser

  Scenario: Viewing subfamilies
    Then I should see "Formicidae" in the index
      And I should see "Dolichoderinae" in the index
      And I should see "Myrmicinae" in the index
    Then I should see "Dolichoderinae" in the browser
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
    When I follow "MYRMICINAE" in the browser
    Then the browser header should be "Subfamily MYRMICINAE"
      And I should see "Myrmicinae" in the browser header
      And I should see "Atta" in the index
      And I should see "Myrmicinae" in the browser
      And I should see "Myrmicinae history" in the browser
      And I should see "Genus ATTA" in the browser
      And I should see "Atta history" in the browser

  Scenario: Clicking a subfamily heading in the browser after a search
    When I fill in the search box with "atta"
      And I press "Go" by the search box
    Then I should see "Atta history"
    When I follow "Myrmicinae" in the index
    Then I should see "Atta" in the index
      And I should see "Myrmicinae" in the index
      And I should see "Atta history" in the browser

  Scenario: Clicking a subfamily heading in the index which is showing genera
    When I follow "MYRMICINAE" in the browser
    Then I should not see "Dolichoderinae" in the index
      And I should see "Atta" in the index
    When I follow "Myrmicinae" in the index
    Then I should not see "Dolichoderinae" in the index
      And I should see "Atta" in the index

  Scenario: Clicking a genus heading in the browser
    When I follow "MYRMICINAE" in the browser
      And I follow "ATTA" in the browser
    Then I should see "nigra" in the index
      And I should see "nigra history" in the browser

  Scenario: Clicking a genus heading in the index which is showing species
    When I follow "MYRMICINAE" in the browser
    Then I should see "Tetramorium" in the index
    When I follow "ATTA" in the browser
      Then I should see "nigra" in the browser
    When I follow "Atta" in the index
      Then I should see "nigra" in the browser

  Scenario: Clicking the family heading in the index which is showing species
    When I follow "MYRMICINAE" in the browser
      Then I should see "Myrmicinae history" in the browser
    When I follow "ATTA" in the browser
      Then I should see "nigra" in the browser
    When I follow "Myrmicinae" in the index
    Then I should see "Myrmicinae history" in the browser
    When I follow "Formicidae" in the index
    Then I should see "Dolichoderinae" in the index

  Scenario: Clicking a subfamily heading in the index which is showing species
    When I follow "MYRMICINAE" in the browser
      Then I should see "Myrmicinae history" in the browser
    When I follow "ATTA" in the browser
      Then I should see "nigra" in the browser
    When I follow "Myrmicinae" in the index
    Then I should see "Myrmicinae history" in the browser

  Scenario: Clicking a subfamily heading in the index which is showing the subfamily
    When I follow "MYRMICINAE" in the browser
    Then I should not see "Dolichoderinae" in the index
      And I should see "Myrmicinae history" in the browser
    When I follow "Myrmicinae" in the index
    Then I should not see "Dolichoderinae" in the index
      And I should see "Myrmicinae history" in the browser

  Scenario: Searching when no results
    When I fill in the search box with "asdfjl;jsdf"
      And I press "Go" by the search box
    Then I should see "No results found"

  Scenario: Searching when only one genus result
    Given I should not see "Atta history"
    When I fill in the search box with "atta"
      And I press "Go" by the search box
    Then I should see "Atta history"

  Scenario: Searching when only one species result
    Given I should not see "nigra history"
    When I fill in the search box with "nigra"
      And I press "Go" by the search box
    Then I should see "Atta nigra history"

  Scenario: Searching when more than one result
    When I fill in the search box with "nigr"
      And I press "Go" by the search box
    Then I should see "Atta nigra" in the search results
      And I should see "Tetramorium nigra" in the search results
      And I should see "Atta history"

  Scenario: Following a search result
    When I fill in the search box with "Att"
      And I press "Go" by the search box
    Then I should see "Atta" in the search results
      And I should see "Tetramorium attaxus" in the search results
      And I should not see "Tetramorium attaxus history" in the browser
    When I follow "Tetramorium attaxus"
      Then I should see "Tetramorium attaxus history" in the browser
      And I should be in "Browser" mode

  Scenario: Going to the index after finding a species
    When I fill in the search box with "nigr"
      And I press "Go" by the search box
      And I follow "Atta nigra" in the search results
      And I choose "Index"
    Then I should see "Atta nigra"

  Scenario: Keeping search results after selecting from the browser index
    When I fill in the search box with "nigr"
      And I press "Go" by the search box
    Then I should see "Atta nigra" in the search results
      And I should see "Tetramorium nigra" in the search results
    When I follow "Myrmicinae" in the index
    Then I should see "Atta nigra" in the search results
      And I should see "Tetramorium nigra" in the search results

  Scenario: Keeping search results after going to the index
    When I fill in the search box with "nigr"
      And I press "Go" by the search box
    Then I should see "Atta nigra" in the search results
      And I should see "Tetramorium nigra" in the search results
    When I choose "Index"
    Then I should see "Atta nigra" in the search results
      And I should see "Tetramorium nigra" in the search results

  Scenario: Finding a genus without a subfamily
    When I fill in the search box with "myrmi"
      And I press "Go" by the search box
    Then I should see "Myrmicinae history"

  Scenario: A genus that replaced another genus
    Given a genus exists with a name of "Dlusskyidris" and a subfamily of "Dolichoderinae" and a taxonomic history of "Dlusskyidris history"
      And a genus that was replaced by "Dlusskyidris" exists with a name of "Palaeomyrmex" with a taxonomic history of "Palaeomyrmex history"
    When I follow "DOLICHODERINAE" in the browser
      Then I should see "Homonym replaced by DLUSSKYIDRIS" in the browser
      Then I should see "Palaeomyrmex" in the browser
      And I should see "Palaeomyrmex" in the index
      And I should not see "Palaeomyrmex" by itself in the browser
    When I follow "DLUSSKYIDRIS" in the browser
    Then I should see "Homonym replaced by DLUSSKYIDRIS" in the browser header
      And I should see "Palaeomyrmex" in the browser header
    #When I follow "Dolichoderinae" in the index
      #And I follow "PALAEOMYRMEX" in the browser
    #Then I should see "Palaeomyrmex" in the browser header
      #And I should not see "Homonym replaced by DLUSSKYIDRIS" in the browser header



