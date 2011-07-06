Feature: Using the catalog
  As a user of AntCat
  I want to use the catalog in both index and browser modes
  Depending on my needs

  Scenario: View mode tab selection
    When I go to the catalog browser
    Then the "Browser" tab should be selected
    When I choose "Index"
    Then the "Index" tab should be selected
    When I choose "Browser"
    Then the "Browser" tab should be selected

  Scenario: Going from index to browser with tribe selected
    Given a subfamily exists with a name of "Dolichoderinae"
      And a tribe exists with a name of "Dolichoderini" and a subfamily of "Dolichoderinae"
    When I go to the catalog index
      And I follow "Dolichoderinae"
      And I follow "Dolichoderini"
      And I choose "Browser"
    Then the browser header should be "Subfamily DOLICHODERINAE"

  #Scenario: Keeping search results after going to the browser
    #When I fill in the search box with "emeryi"
      #And I press "Go" by the search box
      #And I choose "Browser"
    #Then I should see "Tapinoma emeryi" within the search results
      #And I should see "Atta emeryi" within the search results
