Feature: View reference
  As Phil Ward
  I want to change previously entered references
  So that I can fix mistakes

  Scenario: Edit a reference
    Given the following entries exist in the bibliography
      |authors|citation|cite_code|created_at|date    |excel_file_name|notes|possess|title|updated_at|year|
      |Authors|Citation|CiteCode |today     |20100712|ExcelFileName  |Notes|Possess|Title|today     |2010|
    When I go to the main page
      And I follow "Authors 2010 Title Citation Notes"
    Then I should be on the page for that reference
    When I follow "Edit"
    Then I should be on the edit page for that reference
