import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

const application = Application.start()

application.debug = false
window.Stimulus = application

const context = require.context("../controllers", true, /\.js$/)
Stimulus.load(definitionsFromContext(context)) // eslint-disable-line no-undef
