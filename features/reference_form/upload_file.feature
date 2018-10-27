Feature: Upload a file
  As an editor
  I want to upload the document for a reference
  So that people can easily read it

  # TODO: Test never passed for the right reason. Documents hosted on AntCat's
  # servers are cleared, but not files stored on S3.
  Scenario: Clearing the URL after uploading the file
    Given PENDING
    Given I am logged in as a catalog editor
    And there is a reference
    And that the entry has a URL that's on our site

    When I go to the edit page for the most recent reference
    And I fill in "reference_title" with "My Life with the Ants"
    And I fill in "reference_document_attributes_url" with ""
    And I press "Save"
    And I wait
    Then I should not see "PDF"
