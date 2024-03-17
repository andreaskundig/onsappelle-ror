import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "email", "emailList" ]
  // static values = { emails: Array}

  // initialize() {
  //   this.emailsValue
  //       .forEach(email => this.insertEmailItem(
  //         email,
  //         this.emailListTarget))
  // }

  addRecipient(event) {
    event.preventDefault();
    const email = this.emailTarget.value;
    this.insertEmailItem(email, this.emailListTarget);
    this.emailTarget.value = '';
  }

  removeRecipient(event){
    const li = event.target.parentElement.parentElement;
    this.emailListTarget.removeChild(li);
  }

  insertEmailItem(email, listTarget) {
    listTarget.insertAdjacentHTML(
      'beforeend',
    `<li>
      <span>${email}</span>
      <input type="hidden" name="users[][email]" value="${email}" >
      <a data-action="click->recipients#removeRecipient">
      <i class="fa-solid fa-circle-minus"></i></a>
     </li>`);
  }

  connect() {
  }
}
