Feature: View bibliography
  As a researcher
  I want to see what the literature is for ant taxonomy
  So that I can obtain it and read it

  Scenario: View one entry
    Given the following entries exist in the bibliography
      |authors|citation|cite_code|created_at|date    |excel_file_name|notes|possess|title|updated_at|year|
      |Authors|Citation|CiteCode |today     |20100712|ExcelFileName  |Notes|Possess|Title|today     |2010|
    When I go to the main page
    Then I should see "Authors 2010. Title Citation Notes"

  Scenario: View one entry with italics
    Given the following entries exist in the bibliography
      |title|
      |Territory defense by the ant *Azteca trigona*|
    When I go to the main page
    Then I should see "Azteca trigona" in italics

  Scenario: Dangerous text
    Given the following entries exist in the bibliography
      |title|
      |<script>|
    When I go to the main page
    Then I should see "<script>"
