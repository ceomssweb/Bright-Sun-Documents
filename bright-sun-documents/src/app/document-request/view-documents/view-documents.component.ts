import { Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { UsersDocuments } from '../documents-services/document.sevices';
import { Columns, Users } from '../documents-services/users';
import { ToastrService } from 'ngx-toastr';
import { getStorage, ref, deleteObject, uploadBytesResumable, getDownloadURL } from 'firebase/storage';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

@Component({
  selector: 'bsd-view-documents',
  templateUrl: './view-documents.component.html',
  styleUrls: ['./view-documents.component.scss']
})
export class ViewDocumentsComponent implements OnInit {
  page: number = 1;
  userList!: Users[];
  cols!: Columns[];
  dialogHeader!: String;
  dialogEditHeader!: String;
  dialogDoc!: String[];
  showDownBtn!: any;
  hideWhenNouserList: boolean = false;
  noData: boolean = false;
  preLoader: boolean = true;
  showDocDialog: boolean = false;
  showEditDialog: boolean = false;
  file: any = [];
  userPath: string = JSON.parse(localStorage.getItem('user')!).uid;
  getRealDocName!: string[];
  dialogEdit!: any[];
  public editUsersForm!: FormGroup;
  getFilNames: String[] = [];
  getID: any;
  fileNames: String[] = [];
  userEmail: string = '';
  widthContainer: boolean = false;
  widthVal: number = 0;
  constructor(
    public userServices: UsersDocuments, 
    public fb: FormBuilder,
    public toastr: ToastrService
    ) { }

  ngOnInit(): void {
    this.dataState();
    let s = this.userServices.GetUsersList();
    s.snapshotChanges().subscribe(data => {
      this.userList = [];
      data.forEach(item => {
        let getItem: any = item.payload.toJSON(); 
        getItem['key'] = item.key;
        this.getID = item.key;
        this.userList.push(getItem as Users);
        this.fileNames.push(getItem.originalNames);
      });
      
      this.cols = [
        { id: 1, header: 'Full Name' },
        { id: 2, header: 'Father Name' },
        { id: 3, header: 'Email' },
        { id: 4, header: 'Mobile Number' },

        { id: 5, header: 'Document Type' },
        { id: 6, header: 'First Party Name' },
        { id: 7, header: 'First Party Adress' },
        { id: 8, header: 'First Party Age' },
        { id: 9, header: 'First Party Gender' },

        { id: 10, header: 'Relationship' },
        { id: 11, header: 'Second Party Name' },
        { id: 12, header: 'Second Party Adress' },
        { id: 13, header: 'Second Party Age' },
        { id: 14, header: 'Second Party Gender' },
        { id: 15, header: 'Payment Status' },
        { id: 16, header: 'Added Documents' },
    ];
    });
    this.userEditFormData();
  }
  dataState() {     
    this.userServices.GetUsersList().valueChanges().subscribe(data => {
      this.preLoader = false;
      if(data.length <= 0){
        this.hideWhenNouserList = false;
        this.noData = true;
      } else {
        this.hideWhenNouserList = true;
        this.noData = false;
      }
    })
  }
  deleteUsers(user: any) {
    
    if (window.confirm('Are sure you want to delete this student ?')) { 
      
      const storage = getStorage();
      this.getRealDocName = Object.values(user.originalNames);
      for (let i = 0; i < this.getRealDocName.length; i++) {
        const storageRef = ref(storage, 'users-documents/' + this.userPath + '/' + user.email + '/' + this.getRealDocName[i]);
        deleteObject(storageRef).then(() => {
        }).catch((error) => {
          this.toastr.error(user.fullName + ' Not deleted!');
        });
        if(i == this.getRealDocName.length - 1){
          this.userServices.DeleteUsers(user.key);
          this.toastr.success(user.fullName + ' successfully deleted!');
        }
      };
      
        // const childRef = ref.
        // Delete the file
        
        
      
    }
  }
  showDocuments(getPath:any, name:any){
    this.showDocDialog = true;
    this.dialogHeader = name;
    this.dialogDoc = Object.values(getPath);
  }
  hideDocDialog(){
    this.showDocDialog = false;
    this.dialogHeader = "";
  }
  editMyUsers(id:any, user:any){
    //this.dialogEdit = Object.values(list);
    this.dialogEditHeader = user.email;
    this.userEmail = user.email;
    this.userServices
      .GetUsers(id)
      .valueChanges()
      .subscribe((data) => {
        if(data != null){
          this.editUsersForm.setValue(data);
        }
        
      });
      this.getFilNames = Object.values(user.selectedDocuments);
      
    this.showEditDialog = true;
  }

  chooseFile(event: any) {
    for (var i = 0; i < event.target.files.length; i++) { 
      this.file.push(event.target.files[i]);
    }
  }
  updateData() {
    if(this.editUsersForm.valid){
    const storage = getStorage();
    for (var i = 0; i < this.file.length; i++) { 
      this.fileNames.push(this.file[i].name);
      const storageRef = ref(storage, 'users-documents/' + this.userServices.userPath + '/' + this.userEmail + '/' + this.file[i].name);
      const uploadTask = uploadBytesResumable(storageRef, this.file[i]);
      uploadTask.on('state_changed',
        (snapshot) => {
          this.widthContainer=true;
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
            this.getFilNames.push(_downloadURL);
          });
          // this.enableUpdate = true;
        }
      )
    }
  }else{
    alert("Pease fill the form before uploading the Documents!")
  }
}
  
  updateForm() {
    if(this.editUsersForm.valid){
    this.userServices.UpdateUsers(this.editUsersForm.value, this.getFilNames, this.fileNames);
    this.toastr.success(
      this.editUsersForm.controls['fullName'].value + ' updated successfully'
    );
    }
  }
  ResetForm() {
    this.widthVal = 0;
    this.widthContainer = false;
    this.editUsersForm.reset();
  }
  userEditFormData(){
    // if(this.editUsersForm === undefined) {return}
    this.editUsersForm = this.fb.group({
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
      selectedDocuments: [''],
      originalNames: [''],
      paymentStatus: ['']
    });
  }
  hideEditDialog(){
    this.showEditDialog = false;
    this.dialogEditHeader = "";
    this.ResetForm();
  }
}
