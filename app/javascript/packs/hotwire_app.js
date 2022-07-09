import { Application } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

window.Turbo = Turbo

const application = Application.start()

application.debug = false
window.Stimulus = application

const context = require.context("../controllers", true, /\.js$/)
Stimulus.load(definitionsFromContext(context)) // eslint-disable-line no-undef

Turbo.setProgressBarDelay(50)

Turbo.session.drive = false
let DEV_LOG_TURBO_EVENTS = false // eslint-disable-line prefer-const
// DEV_LOG_TURBO_EVENTS = true // Uncomment for debugging.

if (DEV_LOG_TURBO_EVENTS) {
  [
    'turbo:click',
    'turbo:before-visit',
    'turbo:visit',
    'turbo:before-fetch-request',
    'turbo:before-fetch-response',
    'turbo:submit-start',
    'turbo:submit-end',
    'turbo:before-cache',
    'turbo:before-render',
    'turbo:before-stream-render',
    'turbo:render',
    'turbo:load',
    'turbo:frame-render',
    'turbo:frame-load',
  ].forEach((eventName) => {
    document.addEventListener(eventName, () => {
      console.log(`DEV_LOG_TURBO_EVENTS: ${eventName}`)
    })
  })
}
