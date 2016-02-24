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
    Cookies.remove "taxon_browser"
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
      expect(engine._getCookie()).toBeUndefined()
      engine._setCookie true
      expect(engine._getCookie()).toEqual true
      engine._setCookie false
      expect(engine._getCookie()).toEqual false

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
      expect(engine._getCookie()).toBeUndefined()
      $("#desktop-toggler").click()
      expect(engine._getCookie()).toEqual true

    it "handles multiple toggles in a row", ->
      expectItToBeHidden = ->
        expect(engine._isVisible).toBe false
        expect($ "#taxon_browser").toBeHidden()
        expect($ "#desktop-toggler").toHaveText "Show Taxon Browser"
        expect(engine._getCookie()).toBeFalsy()

      expectItToBeVisible = ->
        expect(engine._isVisible).toBe true
        expect($ "#taxon_browser").toBeVisible()
        expect($ "#desktop-toggler").toHaveText "Hide Taxon Browser"
        expect(engine._getCookie()).toEqual true

      expectItToBeHidden()

      $("#desktop-toggler").click() # visible
      $("#desktop-toggler").click() # hidden
      $("#desktop-toggler").click() # visible

      expectItToBeVisible()

      $("#desktop-toggler").click() # hidden
      $("#desktop-toggler").click() # visible

      expectItToBeVisible()

describe "TaxonBrowserToggler Test Env Exception", ->
  engine = null

  beforeEach ->
    fixture.load "taxon_browser_toggler.html"
    window.AntCat.taxon_browser_test_hack = true
    engine = new TaxonBrowserToggler()

  afterEach ->
    window.AntCat.taxon_browser_test_hack = false

  it "is not hidden in test env", ->
    expect($ "#taxon_browser").toBeVisible()

  it "sets @_isVisible correctly", ->
    expect(engine._isVisible).toBe true
