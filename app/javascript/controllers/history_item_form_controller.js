import { Controller } from "@hotwired/stimulus"

// TODO: This was ported pretty much 1-to-1 from jQuery. Use more idiomatic Stimulus.

export default class extends Controller {
  static targets = [
    // Type-specific elements.
    "typeSpecificSubtype",
    "typeSpecificPickedValue",
    "typeSpecificTextValue",
    "typeSpecificReference",
    "typeSpecificPages",
    "typeSpecificObjectProtonym",
    "typeSpecificObjectTaxon",
    "typeSpecificForceAuthorCitation",

    // Type labels.
    "typeLabelSubtype",
    "typeLabelPickedValue",
    "typeLabelTextValue",
    "typeLabelReference",
    "typeLabelPages",
    "typeLabelObjectProtonym",
    "typeLabelObjectTaxon",

    // Type-specific inputs.
    "typeSelect",
    "subtypeSelect",
    "pickedValueSelect", // TODO: Not used?

    // Misc.
    "typeSpecificSection", // Any type-specific section.
    "typeSpecificHelpHomonymReplacedBy",
    "typeSpecificHelpJuniorSynonymOf",
    "typeSpecificHelpReplacementNameFor",
    "typeSpecificHelpSeniorSynonymOf",
    "typeSpecificHelpTaxt",
  ]

  connect() {
    const selectedType = this.typeSelectTarget.value
    this.showHideTypeSpecific(selectedType)

    document.body.setAttribute('data-test-taxt-editors-loaded', "true") // HACK.
  }

  onSelectType(event) {
    const selectedType = event.target.value
    this.showHideTypeSpecific(selectedType)
  }

  showHideTypeSpecific(selectedType) {
    this._resetTypeSpecific()

    const inputsToShow = []
    switch (selectedType) {
      case 'Taxt':
        inputsToShow.push(this.typeSpecificHelpTaxtTarget)
        break

      case 'FormDescriptions':
        this.typeLabelTextValueTarget.textContent = "Forms"
        inputsToShow.push(this.typeSpecificReferenceTarget, this.typeSpecificPagesTarget, this.typeSpecificTextValueTarget)
        break

      case 'TypeSpecimenDesignation':
        this.typeLabelSubtypeTarget.textContent = "Designation type"
        this._setupSelect(this.subtypeSelectTarget, [
          { label: "(none)", value: "" },
          { label: "Lectotype designation", value: "LectotypeDesignation" },
          { label: "Neotype designation", value: "NeotypeDesignation" },
        ])
        inputsToShow.push(this.typeSpecificSubtypeTarget, this.typeSpecificReferenceTarget, this.typeSpecificPagesTarget)
        break

      case 'CombinationIn':
        this.typeLabelObjectTaxonTarget.textContent = "Combination in"
        inputsToShow.push(this.typeSpecificReferenceTarget, this.typeSpecificPagesTarget, this.typeSpecificObjectTaxonTarget)
        break

      case 'JuniorSynonymOf':
        this.typeLabelObjectProtonymTarget.textContent = "Junior synonym of"
        inputsToShow.push(
          this.typeSpecificReferenceTarget,
          this.typeSpecificPagesTarget,
          this.typeSpecificObjectProtonymTarget,
          this.typeSpecificForceAuthorCitationTarget,

          this.typeSpecificHelpJuniorSynonymOfTarget,
        )
        break

      case 'SeniorSynonymOf':
        this.typeLabelObjectProtonymTarget.textContent = "Senior synonym of"
        inputsToShow.push(
          this.typeSpecificReferenceTarget,
          this.typeSpecificPagesTarget,
          this.typeSpecificObjectProtonymTarget,
          this.typeSpecificForceAuthorCitationTarget,

          this.typeSpecificHelpSeniorSynonymOfTarget,
        )
        break

      case 'SubspeciesOf':
        this.typeLabelObjectProtonymTarget.textContent = "Subspecies of"
        inputsToShow.push(
          this.typeSpecificReferenceTarget,
          this.typeSpecificPagesTarget,
          this.typeSpecificObjectProtonymTarget,
          this.typeSpecificForceAuthorCitationTarget,
        )
        break

      case 'StatusAsSpecies':
        this.typeLabelObjectProtonymTarget.textContent = "Senior synonym of"
        inputsToShow.push(this.typeSpecificReferenceTarget, this.typeSpecificPagesTarget)
        break

      case 'JuniorPrimaryHomonymOf':
        this.typeLabelObjectTaxonTarget.textContent = "Junior primary homonym of"
        this._markCitationAsOptional()
        inputsToShow.push(this.typeSpecificReferenceTarget, this.typeSpecificPagesTarget, this.typeSpecificObjectTaxonTarget)
        break

      case 'JuniorPrimaryHomonymOfHardcodedGenus':
        this.typeLabelTextValueTarget.textContent = "Junior primary homonym of hardcoded genus"
        this._markCitationAsOptional()
        inputsToShow.push(this.typeSpecificReferenceTarget, this.typeSpecificPagesTarget, this.typeSpecificTextValueTarget)
        break

      case 'JuniorSecondaryHomonymOf':
        this.typeLabelObjectTaxonTarget.textContent = "Junior secondary homonym of"
        this._markCitationAsOptional()
        inputsToShow.push(this.typeSpecificReferenceTarget, this.typeSpecificPagesTarget, this.typeSpecificObjectTaxonTarget)
        break

      case 'HomonymReplacedBy':
        this.typeLabelObjectTaxonTarget.textContent = "Replacement name (homonym replaced by)"
        this._markCitationAsOptional()
        inputsToShow.push(
          this.typeSpecificReferenceTarget,
          this.typeSpecificPagesTarget,
          this.typeSpecificObjectTaxonTarget,

          this.typeSpecificHelpHomonymReplacedByTarget,
        )
        break

      case 'ReplacementNameFor':
        this.typeLabelObjectTaxonTarget.textContent = "Replacement name for"
        this._markCitationAsOptional()
        inputsToShow.push(
          this.typeSpecificReferenceTarget,
          this.typeSpecificPagesTarget,
          this.typeSpecificObjectTaxonTarget,

          this.typeSpecificHelpReplacementNameForTarget,
        )
        break

      case 'UnavailableName':
        this._markCitationAsOptional()
        inputsToShow.push(this.typeSpecificReferenceTarget, this.typeSpecificPagesTarget)
        break

      default:
        alert(`unknown type: ${selectedType}`)
    }

    (inputsToShow).forEach((input) => {
      input.classList.remove("hidden")
    })
  }

  _resetTypeSpecific() {
    this.typeSpecificSectionTargets.forEach((element) => { element.classList.add("hidden") })

    this.typeLabelSubtypeTarget.textContent = "???"
    this.typeLabelPickedValueTarget.textContent = "???"
    this.typeLabelTextValueTarget.textContent = "???"
    this.typeLabelObjectProtonymTarget.textContent = "???"
    this.typeLabelObjectTaxonTarget.textContent = "???"

    this.typeLabelReferenceTarget.textContent = "Reference"
    this.typeLabelPagesTarget.textContent = "Pages"
  }

  _markCitationAsOptional() {
    this.typeLabelReferenceTarget.textContent = "Optional reference"
    this.typeLabelPagesTarget.textContent = "Optional pages"
  }

  _setupSelect(selectElement, options) {
    const currentValue = selectElement.value

    selectElement.replaceChildren()
    options.forEach((option) => {
      const optionElement = document.createElement("option")
      optionElement.setAttribute("value", option.value)
      optionElement.textContent = option.label
      selectElement.appendChild(optionElement)
    })
    selectElement.value = currentValue
  }
}
