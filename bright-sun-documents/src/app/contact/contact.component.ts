import { Component, OnInit } from '@angular/core';
import { FormControl, Validators } from '@angular/forms';

@Component({
  selector: 'bsd-contact',
  templateUrl: './contact.component.html',
  styleUrls: ['./contact.component.scss']
})
export class ContactComponent implements OnInit {
  email = new FormControl('', [Validators.required, Validators.email]);
  selected: any;
  options: any;
  constructor() {
  }
  ngOnInit(): void {
    this.options = {
      center: {lat: 11.599242, lng: 78.610340},
      zoom: 12
  };
  }
  getErrorMessage() {
    if (this.email.hasError('required')) {
      return 'You must enter a value';
    }

    return this.email.hasError('email') ? 'Not a valid email' : '';
  }
}
