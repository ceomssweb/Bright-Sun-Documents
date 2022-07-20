import { Component, Input, OnInit } from '@angular/core';
import { AngularFireList } from '@angular/fire/compat/database';
import { FormBuilder } from '@angular/forms';
import { getDownloadURL, getStorage, ref } from 'firebase/storage';
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
  preLoader: boolean = false;
  noData: boolean = false;
  hideWhenNouserList: boolean = false;
  docSpinner:boolean = false;
  showDocDialog:boolean = false;
  cols!: Columns[];
  getID: any;
  dialogHeader!: any;
  getRowDoc: any[] = [];
  fileNames: any[] = [];
  @Input() mailKey:any = '';
  @Input() nameKey = '';
  getEmpItems!: Users[];
  getActDoc: any[] = [];

  constructor(
    public authService: AuthService, 
    public userServices: UsersDocuments,
    public fb: FormBuilder,
    public toastr: ToastrService
    ) { }

  ngOnChanges(): void{
    this.dataState();
    this.getEmpItems = [];
    let s = this.userServices.GetPerEmp(this.mailKey.key);
    s.snapshotChanges().subscribe(data => {
      data.forEach(item => {
        let getItem: any = item.payload.toJSON(); 
        getItem['key'] = item.key;
        this.getID = item.key;
        this.getEmpItems.push(getItem as Users);
        this.fileNames.push(getItem.originalNames);
      });
    });
  }

  ngOnInit(): void {
    
    this.cols = [
      { id: 1, header: 'Full Name' },
      { id: 2, header: 'Added Documents' },
      { id: 3, header: 'Payment Status' },
      { id: 4, header: 'Father Name' },
      { id: 5, header: 'Email' },
      { id: 6, header: 'Mobile Number' },

      { id: 7, header: 'Document Type' },
      { id: 8, header: 'First Party Name' },
      { id: 9, header: 'First Party Adress' },
      { id: 10, header: 'First Party Age' },
      { id: 11, header: 'First Party Gender' },

      { id: 12, header: 'Relationship' },
      { id: 13, header: 'Second Party Name' },
      { id: 14, header: 'Second Party Adress' },
      { id: 15, header: 'Second Party Age' },
      { id: 16, header: 'Second Party Gender' },
      
  ];
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

  showDocuments(key: any, user: any){
    this.docSpinner = true;
    this.showDocDialog = true;
    this.dialogHeader = user.email;
    // Get the download URL
    this.getRowDoc = Object.values(user.originalNames);
    const storage = getStorage();
    for(let i = 0; i < this.getRowDoc.length; i++){
      const storageRef = ref(storage, 'users-documents/' + this.mailKey.key + '/' + user.email + '/' + this.getRowDoc[i]);
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

}
