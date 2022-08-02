import { Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { UsersDocuments } from '../documents-services/document.sevices';
import { Columns, Users } from '../documents-services/users';
import { ToastrService } from 'ngx-toastr';
import { getStorage, ref, deleteObject, uploadBytesResumable, getDownloadURL } from 'firebase/storage';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AuthService } from 'src/app/shared/services-firebase/auth.service';

@Component({
  selector: 'bsd-view-documents',
  templateUrl: './view-documents.component.html',
  styleUrls: ['./view-documents.component.scss']
})
export class ViewDocumentsComponent implements OnInit {
  @ViewChild('fileInput', { static: false })
  InputVar!: ElementRef;
  userList!: Users[];
  docSpinner:boolean = false;
  page: number = 1;
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
  uploadfile: any = [];
  userPath: string = JSON.parse(localStorage.getItem('user')!).uid;
  getRealDocName!: string[];
  dialogEdit!: any[];
  public editUsersForm!: FormGroup;
  getID: any;
  fileNames: any[] = [];
  rowFileName: any[] = [];
  userPhone: string = '';
  widthContainer: boolean = false;
  widthContainer1: boolean = false;
  widthVal: number = 0;
  widthVal1: number = 0;
  getRowDoc: any[] = [];
  getActDoc: any[] = [];
  downloadData: any[] = [];
  reset = 'Ready for Processing';
  userDelet:boolean = false;
  getUniNumber!: any;

  constructor(
    public authService: AuthService, 
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
    });
    this.cols = [
      { id: 1, header: 'Actions' },
      
      { id: 2, header: 'Full Name' },
      { id: 3, header: 'Added Documents' },
      { id: 4, header: 'Final Document' },
      { id: 5, header: 'Father Name' },
      { id: 6, header: 'Email' },
      { id: 7, header: 'Mobile Number' },

      { id: 8, header: 'Document Type' },
      { id: 9, header: 'First Party Name' },
      { id: 10, header: 'First Party Adress' },
      { id: 11, header: 'First Party Age' },
      { id: 12, header: 'First Party Gender' },
      { id: 13, header: 'Relationship' },
      { id: 14, header: 'Second Party Name' },
      { id: 15, header: 'Second Party Adress' },
      { id: 16, header: 'Second Party Age' },
      { id: 17, header: 'Second Party Gender' },
      { id: 18, header: 'Payment Status' }
  ];
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
    
    if (window.confirm('Are sure you want to delete this User ?')) { 
      
      const storage = getStorage();
      this.getRealDocName = Object.values(user.originalNames);
      for (let i = 0; i < this.getRealDocName.length; i++) {
        const storageRef = ref(storage, 'users-documents/' + this.userPath + '/' + user.mobileNumber + '/' + this.getRealDocName[i]);
        deleteObject(storageRef).then(() => {
        }).catch((error) => {
          this.toastr.error(user.fullName + ' Not deleted!');
        });
        if(i == this.getRealDocName.length - 1){
          this.userServices.DeleteUsers(user.key);
          this.toastr.success(user.fullName + ' successfully deleted!');
        }
      };
      if(user.finalDocStatus != "Ready for Processing"){
        this.userDelet = true;
        this.deleteFinal(user);
      }
    }
  }
  showDocuments(key: any, user: any){
    this.docSpinner = true;
    this.showDocDialog = true;
    this.dialogHeader = user.fullName;
    // Get the download URL
    this.getRowDoc = Object.values(user.originalNames);
    const storage = getStorage();
    for(let i = 0; i < this.getRowDoc.length; i++){
      const storageRef = ref(storage, 'users-documents/' + this.userPath + '/' + user.mobileNumber + '/' + this.getRowDoc[i]);
      
      getDownloadURL(storageRef)
  .then((url) => {
    this.getActDoc.push(url);
    this.docSpinner = false;
  })
  .catch((error) => {
    // A full list of error codes is available at
    // https://firebase.google.com/docs/storage/web/handle-errors
    switch (error.code) {
      case 'storage/object-not-found':
        // File doesn't exist
        break;
      case 'storage/unauthorized':
        // User doesn't have permission to access the object
        break;
      case 'storage/canceled':
        // User canceled the upload
        break;

      // ...

      case 'storage/unknown':
        // Unknown error occurred, inspect the server response
        break;
    }
  });
    }
  }
  hideDocDialog(){
    this.showDocDialog = false;
    this.dialogHeader = "";
    this.getActDoc = [];
  }
  editMyUsers(id:any, user:any, index: number){
    //this.dialogEdit = Object.values(list);
    this.dialogEditHeader = user.email;
    this.userPhone = user.mobileNumber;
    this.userServices
      .GetUsers(id)
      .valueChanges()
      .subscribe((data) => {
        if(data != null){
          this.editUsersForm.setValue(data);
          this.getUniNumber = data.mobileNumber;
          this.editUsersForm.controls['mobileNumber'].disable();
          this.rowFileName = Object.values(this.fileNames[index]);
        }
        
      });
      
    this.showEditDialog = true;
  }

  chooseFile(event: any) {
    for (var i = 0; i < event.target.files.length; i++) { 
      this.file.push(event.target.files[i]);
    }
  }

  
  updateForm() {
    if(this.getUniNumber == this.editUsersForm.controls['mobileNumber'].value){
    const storage = getStorage();
    if(this.file.length > 0){
    for (var i = 0; i < this.file.length; i++) { 
      this.rowFileName.push(this.file[i].name);
      const storageRef = ref(storage, 'users-documents/' + this.userServices.userPath + '/' + this.userPhone + '/' + this.file[i].name);
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
          
        //   getDownloadURL(uploadTask.snapshot.ref).then((_downloadURL) => {
            
        // });
          // this.enableUpdate = true;
        }
      )
      if(i == (this.file.length - 1)){
        this.InputVar.nativeElement.value = "";
        this.widthVal = 0;
        this.widthContainer = false;
        this.userServices.UpdateUsers(this.editUsersForm.value, this.rowFileName);
          this.toastr.success(
            this.editUsersForm.controls['fullName'].value + ' updated successfully'
          );
      }
    }
  }else{
    this.userServices.UpdateUsers(this.editUsersForm.value, this.rowFileName);
    this.toastr.success(
      this.editUsersForm.controls['fullName'].value + ' updated successfully'
    );
  };
  

    
     }else{
      alert("Do not change existing Phone/Mobile number. Please add new record/user!")
     }
  }
  ResetForm() {
    this.widthVal = 0;
    this.widthContainer = false;
    this.editUsersForm.reset();
    this.getActDoc = [];
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
      originalNames: [''],
      paymentStatus: [''],
      finalDocStatus: ['']
    });
  }
  hideEditDialog(){
    this.showEditDialog = false;
    this.dialogEditHeader = "";
    this.ResetForm();
  }

  chooseOutputFile(event:any){
    this.uploadfile = [];
    for (var i = 0; i < event.target.files.length; i++) { 
      this.uploadfile.push(event.target.files[i]);
      debugger;
    }
  }

  uploadFinalFile(user: any){
      // if(this.editUsersForm.valid){
      this.downloadData = [];
      const storage = getStorage();
      if(this.uploadfile.length > 0){
      for (var i = 0; i < this.uploadfile.length; i++) { 
        
        const storageRef = ref(storage, 'final-document/' + this.userServices.userPath + '/' + user.key + '/' + this.uploadfile[i].name);
        this.downloadData.push(this.uploadfile[i].name);
        const uploadTask = uploadBytesResumable(storageRef, this.uploadfile[i]);
        uploadTask.on('state_changed',
          (snapshot) => {
             this.widthContainer1=true;
            const progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
             this.widthVal1 = progress;
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
              this.downloadData.push(_downloadURL);
              this.userServices.UploadDoc(this.userServices.userPath, user, this.downloadData);
             });
          
          
          
          //   getDownloadURL(uploadTask.snapshot.ref).then((_downloadURL) => {
              
          // });
            // this.enableUpdate = true;
            this.widthContainer1=false;
            this.uploadfile = [];
          }
        )
        
      }
    }else{
      // this.userServices.UpdateUsers(this.editUsersForm.value, this.fileNames);
      // this.toastr.success(
      //   this.editUsersForm.controls['fullName'].value + ' updated successfully'
      // );
    };
  
      
      // }else{
      //   alert("Pease fill all the fields in the form!")
      // }
    
  }

  deleteFinal(data:any){
    if (window.confirm('Are sure you want to delete this Final Document ?')) { 
    const storage = getStorage();
    const storageRef = ref(storage, 'final-document/' + this.userServices.userPath + '/' + data.key +'/' + data.finalDocStatus[0]);
   
        deleteObject(storageRef).then(() => {
          if(!this.userDelet){
            this.userServices.UploadDoc(this.userServices.userPath, data, this.reset);
          }else{
            this.userDelet = false;
          }
        }).catch((error) => {
          this.toastr.error('File Not deleted!');
        });
  }
}
}
