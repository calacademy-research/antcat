import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  disableEnvCss() {
    document.cookie = "disable_env_css=yes"
    window.location.reload()
  }

  enableEnvCss() {
    document.cookie = "disable_env_css=no"
    window.location.reload()
  }
}
