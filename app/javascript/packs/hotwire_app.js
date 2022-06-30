import { Application } from "@hotwired/stimulus"

const application = Application.start()

application.debug = false
window.Stimulus = application

/* eslint-disable */
import ClipboardController from "../controllers/clipboard_controller"
application.register("clipboard", ClipboardController)
/* eslint-enable */
