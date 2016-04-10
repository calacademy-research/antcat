#= require taxon_browser/taxon_browser_toggler
#= require js.cookie

fixture.preload "taxon_browser_toggler.html"

describe "Test Fixtures", ->
  it "loads fixtures", ->
    fixture.load "taxon_browser_toggler.html"
    expect($ "#desktop-toggler").toHaveText "Hide Taxon Browser"
    expect($ "#mobile-toggler").toHaveText "Hide Taxon Browser"
    expect($ "#tiny-toggler").toHaveText "Taxon Browser"

describe "TaxonBrowserToggler", ->
  engine = null

  beforeEach ->
    fixture.load "taxon_browser_toggler.html"
    Cookies.remove "show_browser"
    engine = new TaxonBrowserToggler()

  getCookie = -> Cookies.get "show_browser"
  setCookie = (value) -> Cookies.set "show_browser", value

  describe "clicking a toggler", ->
    it "calls @toggle", ->
      spyOn engine, "toggle"
      $("#desktop-toggler").click()
      expect(engine.toggle).toHaveBeenCalled()

    it "sets @isVisible", ->
      expect(engine.isVisible).toBe false
      $("#desktop-toggler").click()
      expect(engine.isVisible).toBe true

    it "hides the taxon browser", ->
      expect($ "#taxon_browser").toBeHidden()
      $("#desktop-toggler").click()
      expect($ "#taxon_browser").toBeVisible()

    it "updates the labels", ->
      expect($ "#desktop-toggler").toHaveText "Show Taxon Browser"
      $("#desktop-toggler").click()
      expect($ "#desktop-toggler").toHaveText "Hide Taxon Browser"
      expect($ "#mobile-toggler").toHaveText "Hide Taxon Browser"
      expect($ "#tiny-toggler").toHaveText "Taxon Browser"

    it "sets the cookie", ->
      expect(getCookie()).toBeUndefined()
      $("#desktop-toggler").click()
      expect(getCookie()).toBe "true"

  describe "toggling multiple times in a row", ->
    expectItToBeHidden = ->
      expect(engine.isVisible).toBe false
      expect($ "#taxon_browser").toBeHidden()
      expect($ "#desktop-toggler").toHaveText "Show Taxon Browser"
      expect(getCookie()).toBe "false"

    expectItToBeVisible = ->
      expect(engine.isVisible).toBe true
      expect($ "#taxon_browser").toBeVisible()
      expect($ "#desktop-toggler").toHaveText "Hide Taxon Browser"
      expect(getCookie()).toBe "true"

    it "works", ->
      setCookie false
      engine._updateLabels()

      expectItToBeHidden()

      $("#desktop-toggler").click() # visible
      $("#desktop-toggler").click() # hidden
      $("#desktop-toggler").click() # visible

      expectItToBeVisible()

      $("#desktop-toggler").click() # hidden
      $("#desktop-toggler").click() # visible

      expectItToBeVisible()
