import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "dateInput", "emailInput", "recipientList",
                     "recipientEmail", "missingRecipient",
                     "missingDate", "submitButton"]

  initialize() {
    // this.updateErrors();
  }

  updateErrors(){
    const missingRecipient = !this.recipientEmailTargets.length;
    if (missingRecipient) {
      this.missingRecipientTarget.classList.remove('hidden');
    } else {
      this.missingRecipientTarget.classList.add('hidden');
    }

    const missingDate = !this.dateInputTarget.value;
    if (missingDate) {
      this.missingDateTarget.classList.remove('hidden');
    } else {
      this.missingDateTarget.classList.add('hidden');
    }

    const disabled = missingRecipient || missingDate;
    this.submitButtonTarget.disabled = disabled;

  }

  addRecipient(event) {
    event.preventDefault();
    this.emailInputTarget.reportValidity();
    if(this.emailInputTarget.checkValidity()){
      const email = this.emailInputTarget.value;
      this.insertEmailItem(email, this.recipientListTarget);
      this.emailInputTarget.value = '';
      this.updateErrors();
    }
  }

  removeRecipient(event){
    const li = event.target.parentElement.parentElement;
    this.recipientListTarget.removeChild(li);
    this.updateErrors();
  }

  insertEmailItem(email, listTarget) {
    listTarget.insertAdjacentHTML(
      // must be the same html as _user_email_item.erb :(
      'beforeend',
    `<li data-reminder-form-target="recipientEmail">
      <span>${email}</span>
      <input type="hidden" name="users[][email]" value="${email}" >
      <a data-action="click->reminder-form#removeRecipient">
      <i class="fa-solid fa-circle-minus"></i></a>
     </li>`);
  }

  connect() {
  }
}
