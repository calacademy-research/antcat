@dormant @javascript
Feature: Copy reference
  As Phil Ward
  I want to add new references using existing reference data
  So that I can reduce copy and pasting beteen references
  And so that the bibliography continues to be up-to-date

  Scenario: Copy a reference
    When I go to the references page
      And I log in
      And the following references exist
      |authors   |title         |citation|year|
      |Ward, P.S.|Annals of Ants|Ants 1:2|1910|
    When I go to the references page
      And I follow "copy"
    Then I should see a new edit form
    When in the new edit form I fill in "reference_title" with "Tapinoma"
      And in the new edit form I fill in "reference_citation_year" with "2010"
      And in the new edit form I press the "Save" button
    Then I should see "2010. Tapinoma."

  Scenario: Copy a reference with a document
    Given I am logged in
      And the following references exist
      |authors   |title         |citation|year|
      |Ward, P.S.|Annals of Ants|Ants 1:2|1910|
      And that the entry has a URL that's on our site
    When I go to the references page
      And I follow "copy"
      And in the new edit form I fill in "reference_title" with "Tapinoma"
      And in the new edit form I fill in "reference_citation_year" with "2010"
      And in the new edit form I press the "Save" button
    Then I should see "2010. Tapinoma."

  Scenario: Copy a reference with a cite code and date
    Given I am logged in
      And the following references exist
      |authors   |title         |citation|year|cite_code|date|
      |Ward, P.S.|Annals of Ants|Ants 1:2|1910|ABCD     |19900101|
      And that the entry has a URL that's on our site
    When I go to the references page
      And I copy "Ward"
    Then in the new edit form the "reference_title" field should contain "Annals of Ants"
      And in the new edit form the "reference_cite_code" field should not contain "ABCD"
      And in the new edit form the "reference_date" field should not contain "19900101"
