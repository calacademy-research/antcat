@dormant @javascript
Feature: Upload a file
  As an editor
  I want to upload the document for a reference
  So that people can easily read it

  Scenario: Upload file
    Given I am logged in
    And these references exist
      | authors    | title | citation   | year |
      | Ward, P.S. | Ants  | Psyche 5:3 | 2010 |
    When I go to the references page
    And I follow "edit"
    And I choose a file to upload
    And I press the "Save" button
    And I wait for a while
    Then I should see a link to that file

  Scenario: Clearing the URL after uploading the file
    Given I am logged in
    And these references exist
      | authors    | title          | citation | year |
      | Ward, P.S. | Annals of Ants | Ants 1:2 | 1910 |
    And that the entry has a URL that's on our site
    When I go to the references page
    And I follow "edit"
    And I fill in "reference_title" with "My Life with the Ants"
    And I fill in "reference_document_attributes_url" with ""
    And I press the "Save" button
    Then I should not see a "PDF" link
