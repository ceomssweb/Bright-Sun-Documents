import { Component, OnInit } from '@angular/core';
import { AuthService } from 'src/app/shared/services-firebase/auth.service';
UsersDocuments
import { UsersDocuments } from './send-services/send-document.sevices';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { ref, uploadBytesResumable, getDownloadURL, getStorage } from "@angular/fire/storage";

@Component({
  selector: 'bsd-send-documents',
  templateUrl: './send-documents.component.html',
  styleUrls: ['./send-documents.component.scss']
})
export class SendDocumentsComponent implements OnInit {
  public usersForm!: FormGroup;
  file: any = [];
  constructor(
    public authService: AuthService,
    public userApi: UsersDocuments,
    public fb: FormBuilder,
    public toastr: ToastrService,

  ) {}

  ngOnInit(): void {
    const getSPValue = JSON.parse(localStorage.getItem('user')!).uid;
    this.userApi.GetUsersList(getSPValue);
    this.userFormData();
  }

  chooseFile(event: any) {
    this.file = event.target.files[0];
    console.log(this.file);
  }
  addData() {
    const storage = getStorage();
    const storageRef = ref(storage, 'images/' + this.file.name);
    const uploadTask = uploadBytesResumable(storageRef, this.file);
    uploadTask.on('state_changed',
      (snapshot) => {
        const progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        console.log('Upload is ' + progress + '% done');
      },
      (error) => {
        console.log(error.message);
        switch (error.code) {
          case 'storage/unauthorized':
            break;
          case 'storage/canceled':
            break;
          case 'storage/unknown':
            break;
        }
      },
      () => {
        getDownloadURL(uploadTask.snapshot.ref).then((downloadURL) => {
          console.log('File available at', downloadURL);
        });
      }
    )
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

  uploadFiles() { }

}
