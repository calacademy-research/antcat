import { Application } from "@hotwired/stimulus"

const application = Application.start()

application.debug = false
window.Stimulus = application

/* eslint-disable */
import ClipboardController from "../controllers/clipboard_controller"
application.register("clipboard", ClipboardController)

import HoverPreviewController from "../controllers/hover_preview_controller"
application.register("hover-preview", HoverPreviewController)
/* eslint-enable */
