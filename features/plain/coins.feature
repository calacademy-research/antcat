Feature: COinS formatting
  As a researcher
  I want to use Zotero to extract citations from ANTBIB
  So that I don't have to hand-copy them myself
  And so I can use the citations in my own documents

  Scenario: Including COinS on index page
    Given the following entries exist in the bibliography
      |authors|kind|title|year|citation|
      |AUTHORS|journal|TITLE|1999|Ecology Letters 12:324-333.|
    When I go to the main page
    Then there should be the HTML "<span class="Z3988" title="ctx_ver=Z39.88-2004"
      And there should be the HTML "rft.atitle=TITLE"
