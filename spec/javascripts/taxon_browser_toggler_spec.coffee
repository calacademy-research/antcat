#= require taxon_browser_toggler
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

  describe "initialization", ->
    it "hides the taxon browser by default", ->
      expect($ "#taxon_browser").toBeHidden()

    it "sets @_isVisible correctly", ->
      expect(engine._isVisible).toBe false

    it "updates labels", ->
      expect($ "#desktop-toggler").toHaveText "Show Taxon Browser"
      expect($ "#mobile-toggler").toHaveText "Show Taxon Browser"
      expect($ "#tiny-toggler").toHaveText "Taxon Browser"

  describe "Methods", ->
    it "can read and write cookies", ->
      expect(engine._getCookie()).toBe false
      engine._setCookie true
      expect(engine._getCookie()).toBe true
      engine._setCookie false
      expect(engine._getCookie()).toBe false

  describe "Toggle Click Handler", ->
    it "calls @toggle", ->
      spyOn engine, "toggle"
      $("#desktop-toggler").click()
      expect(engine.toggle).toHaveBeenCalled()

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

    it "updates @_isVisible", ->
      expect(engine._isVisible).toBe false
      $("#desktop-toggler").click()
      expect(engine._isVisible).toBe true

    it "sets the cookie", ->
      expect(engine._getCookie()).toBe false
      $("#desktop-toggler").click()
      expect(engine._getCookie()).toBe true

    it "handles multiple toggles in a row", ->
      expectItToBeHidden = ->
        expect(engine._isVisible).toBe false
        expect($ "#taxon_browser").toBeHidden()
        expect($ "#desktop-toggler").toHaveText "Show Taxon Browser"
        expect(engine._getCookie()).toBe false

      expectItToBeVisible = ->
        expect(engine._isVisible).toBe true
        expect($ "#taxon_browser").toBeVisible()
        expect($ "#desktop-toggler").toHaveText "Hide Taxon Browser"
        expect(engine._getCookie()).toBe true

      expectItToBeHidden()

      $("#desktop-toggler").click() # visible
      $("#desktop-toggler").click() # hidden
      $("#desktop-toggler").click() # visible

      expectItToBeVisible()

      $("#desktop-toggler").click() # hidden
      $("#desktop-toggler").click() # visible

      expectItToBeVisible()
