import { Component, OnInit } from '@angular/core';
import { AuthService } from 'src/app/shared/services-firebase/auth.service';
UsersDocuments
import { UsersDocuments } from './send-services/send-document.sevices';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { ref, uploadBytesResumable, getDownloadURL, getStorage } from "@angular/fire/storage";
import { Dropdown } from './send-services/dropdowns'

@Component({
  selector: 'bsd-send-documents',
  templateUrl: './send-documents.component.html',
  styleUrls: ['./send-documents.component.scss']
})
export class SendDocumentsComponent implements OnInit {
  documents: Dropdown[];
  selectedDoc!: Dropdown;

  gender: Dropdown[];
  selectedGender!: Dropdown;

  buyerRelation: Dropdown[];
  selectBuyerRelation!: Dropdown;

  public usersForm!: FormGroup;
  file: any = [];
  userPath: string = JSON.parse(localStorage.getItem('user')!).uid;
  widthVal: number = 0;
  constructor(
    public authService: AuthService,
    public userApi: UsersDocuments,
    public fb: FormBuilder,
    public toastr: ToastrService,

  ) {
    this.documents = [
      {key: 1, name: 'Buiding sales deed'},
      {key: 2, name: 'Land sales deed'},
      {key: 3, name: 'Plot Sales deed'},
      {key: 4, name: 'Commertial Buiding sales deed'},
      {key: 5, name: 'Settlement deed'},
      {key: 6, name: 'Rental Aggrements'},
      {key: 7, name: 'Settlement deed'},
      {key: 8, name: 'Partition deed'},
      {key: 9, name: 'Partnership Aggreement'},
  ];
  this.gender = [
    {key: 1, name: 'Male'},
      {key: 2, name: 'Female'},
      {key: 3, name: 'Others'},
  ];
  this.buyerRelation = [
    {key: 1, name: 'Father'},
      {key: 2, name: 'Mother'},
      {key: 3, name: 'Brother'},
      {key: 4, name: 'Sister'},
      {key: 5, name: 'Husband'},
      {key: 6, name: 'Wife'},
      {key: 7, name: 'Grand Father'},
      {key: 8, name: 'Grand Mother'},
      {key: 9, name: 'No Relation'}
  ]

  }

  ngOnInit(): void {
    this.userApi.GetUsersList(this.userPath);
    this.userFormData();
  }

  chooseFile(event: any) {
    for (var i = 0; i < event.target.files.length; i++) { 
      this.file.push(event.target.files[i]);
    }
  }
  addData() {
    const storage = getStorage();
    this.userPath = JSON.parse(localStorage.getItem('user')!).uid
    for (var i = 0; i < this.file.length; i++) { 
      const storageRef = ref(storage, 'users-documents/' + this.userPath + '/' + this.file[i].name);
      const uploadTask = uploadBytesResumable(storageRef, this.file[i]);
   
      uploadTask.on('state_changed',
        (snapshot) => {
          const progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          this.widthVal = progress;
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
          getDownloadURL(uploadTask.snapshot.ref).then((_downloadURL) => {
            // console.log('File available at', downloadURL);
          });
        }
      )
    }
  }

  userFormData() {
    this.usersForm = this.fb.group({
      fullName: ['', [Validators.required, Validators.minLength(2)]],
      fatherName: ['', [Validators.required, Validators.minLength(2)]],
      email: [
        '',
        [
          Validators.required,
          Validators.pattern('^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$'),
        ],
      ],
      mobileNumber: ['', [Validators.required, Validators.pattern('^[0-9]+$')]],
      selectedDoc: [''],
      currentOwnerName: ['', [Validators.required, Validators.minLength(2)]],
      currentOwnerAddress: ['', [Validators.required, Validators.minLength(2)]],
      currentOwnerAge: ['', [Validators.required, Validators.minLength(1)]],
      selectedGender: ['', [Validators.required, Validators.minLength(2)]],
      selectBuyerRelation: ['', [Validators.required, Validators.minLength(2)]],
      buyerName: ['', [Validators.required, Validators.minLength(2)]],
      buyerAddress: ['', [Validators.required, Validators.minLength(2)]],
      buyerAge: ['', [Validators.required, Validators.minLength(1)]],
      selectedBuyGender: ['', [Validators.required, Validators.minLength(2)]],
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
