Feature: View bibliography
  As a researcher
  I want to see what the literature is for ant taxonomy
  So that I can obtain it and read it

  Scenario: View one entry
    Given the following entries exist in the bibliography
      |authors|citation|cite_code|created_at|date    |public_notes|editor_notes|possess|title|updated_at|year|
      |Authors|Citation|CiteCode |today     |20100712|Public notes|Editor's notes|Possess|Title|today     |2010|
    When I go to the main page
    Then I should see "Authors 2010. Title Citation"
      And I should see "Public notes"
      And I should see "Editor's notes"

  Scenario: View one entry with italics
    Given the following entries exist in the bibliography
      |title|
      |Territory \|defense\| by the ant *Azteca trigona*|
    When I go to the main page
    Then I should see "Azteca trigona" in italics
      And I should see "defense" in italics

  Scenario: Dangerous text
    Given the following entries exist in the bibliography
      |title|
      |<script>|
    When I go to the main page
    Then I should see "<script>"

  Scenario: Viewing more than one entry, sorted by author + date (including slug)
    Given the following entries exist in the bibliography
      |authors       |year |title                      |citation                    |
      |Wheeler, W. M.|1910b|Ants.                      |New York.                   |
      |Forel, A.     |1874 |Les fourmis de la Suisse.  |Neue Denkschriften 26:1-452.|
      |Wheeler, W. M.|1910a|Small artificial ant-nests.|Psyche.                     |
    When I go to the main page
    Then I should see these entries in this order:
      |entry|
      |Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.|
      |Wheeler, W. M. 1910a. Small artificial ant-nests. Psyche.|
      |Wheeler, W. M. 1910b. Ants. New York.|

