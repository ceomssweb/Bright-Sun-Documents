import { Component, OnInit } from '@angular/core';
import { AuthService } from 'src/app/shared/services-firebase/auth.service';
import { UsersDocuments } from '../documents-services/document.sevices';
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
  widthVal: number = 0;
  getFilNames!: any;
  enableAdd: boolean = false;
  constructor(
    public authService: AuthService,
    public userApi: UsersDocuments,
    public fb: FormBuilder,
    public toastr: ToastrService,

  ) {

  }

  ngOnInit(): void {
    this.userApi.GetUsersList();
    this.userFormData();
  }

  chooseFile(event: any) {
    for (var i = 0; i < event.target.files.length; i++) { 
      this.file.push(event.target.files[i]);
    }
  }
  addData() {
    const storage = getStorage();
    this.getFilNames = ref(storage, 'users-documents/' + this.userApi.userPath);
    for (var i = 0; i < this.file.length; i++) { 
      const storageRef = ref(storage, 'users-documents/' + this.userApi.userPath + '/' + this.file[i].name);
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
            //  this.getFilNames += '<a class="nav-link">' +_downloadURL + '</a> <br>';
          });
          this.enableAdd = true;
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
      selectedDoc: ['', [Validators.required, Validators.minLength(2)]],
      currentOwnerName: ['', [Validators.required, Validators.minLength(2)]],
      currentOwnerAddress: ['', [Validators.required, Validators.minLength(2)]],
      currentOwnerAge: ['', [Validators.required, Validators.minLength(1)]],
      currentOwnergender: ['', [Validators.required, Validators.minLength(2)]],
      selectBuyerRelation: ['', [Validators.required, Validators.minLength(2)]],
      buyerName: ['', [Validators.required, Validators.minLength(2)]],
      buyerAddress: ['', [Validators.required, Validators.minLength(2)]],
      buyerAge: ['', [Validators.required, Validators.minLength(1)]],
      selectedBuyGender: ['', [Validators.required, Validators.minLength(2)]],
      selectedDocuments: ['', [Validators.required]]
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
    this.enableAdd = false;
    this.widthVal = 0;
  }
  submitUserData() {
    if(!this.usersForm.invalid && this.enableAdd){
      this.userApi.AddUsers(this.usersForm.value, this.getFilNames);
      this.toastr.success(
        this.usersForm.controls['fullName'].value + ' successfully added!'
      );
      this.ResetForm();
    }
  }

}
