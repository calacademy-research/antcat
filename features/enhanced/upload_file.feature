Feature: Upload a file
  As an editor
  I want to upload the document for a reference
  So that people can easily read it

  Scenario: Upload file
    Given I am logged in
      And the following references exist
      |authors   |title|citation  |year|
      |Ward, P.S.|Ants |Psyche 5:3|2010|
    When I go to the main page
      And I follow "edit"
      And I choose a file to upload
      And I press the "Save" button
    Then I should see a link to that file
    When I follow "PDF"
    Then I should be redirected to Amazon
