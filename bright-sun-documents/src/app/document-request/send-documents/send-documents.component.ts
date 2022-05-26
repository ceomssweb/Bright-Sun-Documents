import { Component, OnInit } from '@angular/core';
import { AuthService } from 'src/app/shared/services-firebase/auth.service';
UsersDocuments
import { UsersDocuments } from './send-services/send-document.sevices';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
@Component({
  selector: 'bsd-send-documents',
  templateUrl: './send-documents.component.html',
  styleUrls: ['./send-documents.component.scss']
})
export class UsersDocumentsComponent implements OnInit {
  public usersForm!: FormGroup;
  constructor(
    public authService: AuthService, 
    public userApi: UsersDocuments,
    public fb: FormBuilder,
    public toastr: ToastrService
    ) { }

  ngOnInit(): void {
    this.userApi.GetUsersList();
    this.userFormData();
  }

  userFormData() {
    this.usersForm = this.fb.group({
      firstName: ['', [Validators.required, Validators.minLength(2)]],
      lastName: [''],
      email: [
        '',
        [
          Validators.required,
          Validators.pattern('^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$'),
        ],
      ],
      mobileNumber: ['', [Validators.required, Validators.pattern('^[0-9]+$')]],
    });
  }

  get firstName() {
    return this.usersForm.get('firstName');
  }
  get lastName() {
    return this.usersForm.get('lastName');
  }
  get email() {
    return this.usersForm.get('email');
  }
  get mobileNumber() {
    return this.usersForm.get('mobileNumber');
  }
  ResetForm() {
    this.usersForm.reset();
  }
  submitStudentData() {
    this.userApi.AddUsers(this.usersForm.value);
    this.toastr.success(
      this.usersForm.controls['firstName'].value + ' successfully added!'
    );
    this.ResetForm();
  }

}
