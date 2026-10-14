import { Turbo } from "@hotwired/turbo-rails"

import AWN from "awesome-notifications"

// Starts Stimulus (exposed as `window.Stimulus`) and registers all controllers. Controllers connect
// once the DOM is ready, after this file has run. `controllers/index.js` is generated: run
// `./bin/rails stimulus:manifest:update` after adding a controller.
import "./controllers"

window.AntCat = window.AntCat || {}
window.AntCat.notifier = new AWN({
  position: "top-right",
  labels: { success: "", alert: "" },
})

window.AntCat.notifySuccess = (message) => { window.AntCat.notifier.success(message, {}) }
window.AntCat.notifyError = (message) => { window.AntCat.notifier.alert(message, {}) }

window.Turbo = Turbo

Turbo.setProgressBarDelay(50)

Turbo.session.drive = false
const DEV_LOG_TURBO_EVENTS = false
// const DEV_LOG_TURBO_EVENTS = true // Uncomment for debugging.

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
