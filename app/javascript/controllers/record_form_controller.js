import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "prescriptionYes",
    "prescriptionNameField",
    "testDoneYes",
    "testTypeField"
  ]

  connect() {
    this.togglePrescriptionField()
    this.toggleTestTypeField()
  }

  togglePrescriptionField() {
    if (this.prescriptionYesTarget.checked) {
      this.prescriptionNameFieldTarget.classList.remove("hidden")
    } else {
      this.prescriptionNameFieldTarget.classList.add("hidden")
    }
  }

  toggleTestTypeField() {
    if (this.testDoneYesTarget.checked) {
      this.testTypeFieldTarget.classList.remove("hidden")
    } else {
      this.testTypeFieldTarget.classList.add("hidden")
    }
  }
}

