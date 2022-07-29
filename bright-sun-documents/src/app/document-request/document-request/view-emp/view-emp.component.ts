import { Component, Input, OnInit } from '@angular/core';
import { AngularFireList } from '@angular/fire/compat/database';
import { FormBuilder } from '@angular/forms';
import { deleteObject, getDownloadURL, getStorage, ref, uploadBytesResumable } from 'firebase/storage';
import { ToastrService } from 'ngx-toastr';
import { MenuItem } from 'primeng/api';
import { AuthService } from 'src/app/shared/services-firebase/auth.service';
import { UsersDocuments } from '../../documents-services/document.sevices';
import { Columns, Users } from '../../documents-services/users';

@Component({
  selector: 'bsd-view-emp',
  templateUrl: './view-emp.component.html',
  styleUrls: ['./view-emp.component.scss']
})
export class ViewEmpComponent implements OnInit {
  page = 1;
  reset = 'Ready for Processing';
  preLoader: boolean = false;
  noData: boolean = false;
  widthContainer:boolean = false;
  widthVal:number = 0;
  hideWhenNouserList: boolean = false;
  docSpinner:boolean = false;
  showDocDialog:boolean = false;
  cols!: Columns[];
  getID: any;
  dialogHeader!: any;
  getRowDoc: any[] = [];
  @Input() mailKey:any = '';
  @Input() nameKey = '';
  getEmpItems!: Users[];
  getActDoc: any[] = [];
  file: any = [];
  downloadData:any =[];

  constructor(
    public authService: AuthService, 
    public userServices: UsersDocuments,
    public fb: FormBuilder,
    public toastr: ToastrService
    ) { }

  ngOnChanges(): void{
    this.dataState();
    let s = this.userServices.GetPerEmp(this.mailKey.key);
    s.snapshotChanges().subscribe(data => {
      this.getEmpItems = [];
      data.forEach(item => {
        let getItem: any = item.payload.toJSON();
        getItem['key'] = item.key;
        this.getID = item.key;
        this.getEmpItems.push(getItem as Users);
      });
    });
  }

  ngOnInit(): void {
    
    this.cols = [
      { id: 1, header: 'Full Name' },
      { id: 2, header: 'Added Documents' },
      { id: 3, header: 'Payment Status' },
      { id: 4, header: 'Final Document' },
      { id: 5, header: 'Document Type' },
      { id: 6, header: 'Email' },
      { id: 7, header: 'Mobile Number' },

      { id: 8, header: 'Father Name' },
      { id: 9, header: 'First Party Name' },
      { id: 10, header: 'First Party Adress' },
      { id: 11, header: 'First Party Age' },
      { id: 12, header: 'First Party Gender' },

      { id: 13, header: 'Relationship' },
      { id: 14, header: 'Second Party Name' },
      { id: 15, header: 'Second Party Adress' },
      { id: 16, header: 'Second Party Age' },
      { id: 17, header: 'Second Party Gender' },
      
  ];
  }
  
  dataState() {     
    this.userServices.GetPerEmp(this.mailKey.key).valueChanges().subscribe(data => {
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

  chooseOutputFile(event:any){
    this.file = [];
    for (var i = 0; i < event.target.files.length; i++) { 
      this.file.push(event.target.files[i]);
    }
  }

  uploadFinalFile(user: any){
      // if(this.editUsersForm.valid){
      const storage = getStorage();
      if(this.file.length > 0){
      for (var i = 0; i < this.file.length; i++) { 
        
        const storageRef = ref(storage, 'final-document/' + this.mailKey.key + '/' + user.key + '/' + this.file[i].name);
        this.downloadData.push(this.file[i].name);
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
              this.downloadData.push(_downloadURL);
              this.userServices.UploadDoc(this.mailKey.key, user, this.downloadData);
             });
          
          
          
          //   getDownloadURL(uploadTask.snapshot.ref).then((_downloadURL) => {
              
          // });
            // this.enableUpdate = true;
            this.widthContainer=false;
            this.file = [];
          }
        )
        
      }
    };
    
  }

  showDocuments(key: any, user: any){
    this.docSpinner = true;
    this.showDocDialog = true;
    this.dialogHeader = user.fullName;
    // Get the download URL
    this.getRowDoc = Object.values(user.originalNames);
    const storage = getStorage();
    for(let i = 0; i < this.getRowDoc.length; i++){
      const storageRef = ref(storage, 'users-documents/' + this.mailKey.key + '/' + user.mobileNumber + '/' + this.getRowDoc[i]);
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
    
// .catch((error) => {
//   // A full list of error codes is available at
//   // https://firebase.google.com/docs/storage/web/handle-errors
//   switch (error.code) {
//     case 'storage/object-not-found':
//       // File doesn't exist
//       break;
//     case 'storage/unauthorized':
//       // User doesn't have permission to access the object
//       break;
//     case 'storage/canceled':
//       // User canceled the upload
//       break;

//     // ...

//     case 'storage/unknown':
//       // Unknown error occurred, inspect the server response
//       break;
//   }
// });
  }

  hideDocDialog(){
    this.showDocDialog = false;
    this.dialogHeader = "";
    this.getActDoc = [];
  }
  
  deleteFinal(data:any){
    
    const storage = getStorage();
    const storageRef = ref(storage, 'final-document/' + this.mailKey.key + '/' + data.key +'/' + data.finalDocStatus[0]);
   
        deleteObject(storageRef).then(() => {
          this.userServices.UploadDoc(this.mailKey.key, data, this.reset);
        }).catch((error) => {
          this.toastr.error('File Not deleted!');
        });
  }
}
