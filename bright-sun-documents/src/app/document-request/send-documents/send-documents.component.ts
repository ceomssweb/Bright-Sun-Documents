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
    public toastr: ToastrService,
    ) { }

  ngOnInit(): void {
    const getSPValue = JSON.parse(localStorage.getItem('user')!).uid;
    console.log(getSPValue);
    this.userApi.GetUsersList(getSPValue);
    this.userFormData();
  }

  userFormData() {
    this.usersForm = this.fb.group({
      fullName: ['', [Validators.required, Validators.minLength(2)]],
      parentName: ['', [Validators.required, Validators.minLength(2)]],
      email: [
        '',
        [
          Validators.required,
          Validators.pattern('^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$'),
        ],
      ],
      mobileNumber: ['', [Validators.required, Validators.pattern('^[0-9]+$')]],
      docType: [''],
      currentOwnerName: ['', [Validators.required, Validators.minLength(2)]],
      currentOwnerAddress: ['', [Validators.required, Validators.minLength(2)]],
      currentOwnerAge: ['', [Validators.required, Validators.minLength(1)]],
      currentOwnerSex: ['', [Validators.required, Validators.minLength(2)]],
      buyerRelationType: ['', [Validators.required, Validators.minLength(2)]],
      buyerName: ['', [Validators.required, Validators.minLength(2)]],
      buyerAddress: ['', [Validators.required, Validators.minLength(2)]],
      buyerAge: ['', [Validators.required, Validators.minLength(1)]],
      buyerSex: ['', [Validators.required, Validators.minLength(2)]],
      uploadFiles: [''],
    });
  }

  get fullName() {
    return this.usersForm.get('fullName');
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
  submitUserData() {
    this.userApi.AddUsers(this.usersForm.value);
    this.toastr.success(
      this.usersForm.controls['fullName'].value + ' successfully added!'
    );
    this.ResetForm();
  }

  uploadFiles(){}

}
