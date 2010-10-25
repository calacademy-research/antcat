Feature: View bibliography
  As a researcher
  I want to see what the literature is for ant taxonomy
  So that I can obtain it and read it

  Scenario: View one entry
    Given the following entries exist in the bibliography
      |authors   |year |title    |citation|cite_code|possess|date    |notes                       |
      |Ward, P.S.|2010d|Ant Facts|Ants 1:1|232      |PSW    |20100712|{Public notes}Editor's notes|
    When I go to the main page
    Then I should see "Ward, P.S. 2010d. Ant Facts. Ants 1:1. [2010-07-12]"
      And I should see "Public notes"
      And I should see "Editor's notes"

  Scenario: View one entry with italics
    Given the following entries exist in the bibliography
      |title                                            |authors|citation|year|
      |Territory \|defense\| by the ant *Azteca trigona*|authors|Ants 2:2|year|
    When I go to the main page
    Then I should see "Azteca trigona" in italics
      And I should see "defense" in italics

  Scenario: Dangerous text
    Given the following entries exist in the bibliography
      |title   |authors|citation|year|notes |
      |<script>|authors|Ants 3:3|year|<html>|
    When I go to the main page
    Then I should see "<script>"
      And I should see "<html>"

  Scenario: Viewing more than one entry, sorted by author + date (including slug)
    Given the following entries exist in the bibliography
      |authors       |year |title                     |citation                   |
      |Wheeler, W. M.|1910b|Ants                      |Psyche 2:2                 |
      |Forel, A.     |1874 |Les fourmis de la Suisse  |Neue Denkschriften 26:1-452|
      |Wheeler, W. M.|1910a|Small artificial ant-nests|Psyche 1:1                 |
    When I go to the main page
    Then I should see these entries in this order:
      |entry|
      |Forel, A. 1874. Les fourmis de la Suisse. Neue Denkschriften 26:1-452.|
      |Wheeler, W. M. 1910a. Small artificial ant-nests. Psyche 1:1.|
      |Wheeler, W. M. 1910b. Ants. Psyche 2:2|

  Scenario: Viewing an entry with a source URL to a document on our site, but the user isn't logged in
    Given the following entries exist in the bibliography
      |authors   |year |title    |citation|cite_code|possess|date    |notes                       |
      |Ward, P.S.|2010d|Ant Facts|Ants 1:1|232      |PSW    |20100712|{Public notes}Editor's notes|
      And that the entry has a source URL that's on our site
    When I go to the main page
    Then I should not see a "PDF" link

  Scenario: Viewing an entry with a source URL to a document that's not on our site, and the user isn't logged in
    Given the following entries exist in the bibliography
      |authors   |year |title    |citation|cite_code|possess|date    |notes                       |
      |Ward, P.S.|2010d|Ant Facts|Ants 1:1|232      |PSW    |20100712|{Public notes}Editor's notes|
      And that the entry has a source URL that's not on our site
    When I go to the main page
    Then I should see a "PDF" link

  Scenario: Viewing an entry with a source URL to a document on our site, but the user is logged in
    Given the following entries exist in the bibliography
      |authors   |year |title    |citation|cite_code|possess|date    |notes                       |
      |Ward, P.S.|2010d|Ant Facts|Ants 1:1|232      |PSW    |20100712|{Public notes}Editor's notes|
      And that the entry has a source URL that's on our site
      And I am logged in
    When I go to the main page
    Then I should see a "PDF" link

  Scenario: Viewing an entry with a source URL to a document that's not on our site, and the user is logged in
    Given the following entries exist in the bibliography
      |authors   |year |title    |citation|cite_code|possess|date    |notes                       |
      |Ward, P.S.|2010d|Ant Facts|Ants 1:1|232      |PSW    |20100712|{Public notes}Editor's notes|
      And that the entry has a source URL that's not on our site
      And I am logged in
    When I go to the main page
    Then I should see a "PDF" link

  Scenario: Viewing an entry with a source URL to a document on our site, but the user is logged in
    Given the following entries exist in the bibliography
      |authors   |year |title    |citation|cite_code|possess|date    |notes                       |
      |Ward, P.S.|2010d|Ant Facts|Ants 1:1|232      |PSW    |20100712|{Public notes}Editor's notes|
      And that the entry has a source URL that's on our site
      And I am logged in
    When I go to the main page
    Then I should see a "PDF" link

  Scenario: Viewing an entry with a source URL to a document that's not on our site, and the user is logged in
    Given the following entries exist in the bibliography
      |authors   |year |title    |citation|cite_code|possess|date    |notes                       |
      |Ward, P.S.|2010d|Ant Facts|Ants 1:1|232      |PSW    |20100712|{Public notes}Editor's notes|
      And that the entry has a source URL that's not on our site
      And I am logged in
    When I go to the main page
    Then I should see a "PDF" link

