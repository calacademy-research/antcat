import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  disableEnvCss() {
    document.cookie = "disable_env_css=yes"
  }

  enableEnvCss() {
    document.cookie = "disable_env_css=no"
  }
}
