import { Component, OnInit } from '@angular/core';
import { UsersDocuments } from '../documents-services/document.sevices';
import { Columns, Users } from '../documents-services/users';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'bsd-view-documents',
  templateUrl: './view-documents.component.html',
  styleUrls: ['./view-documents.component.scss']
})
export class ViewDocumentsComponent implements OnInit {
  p: number = 1;
  userList!: Users[];
  cols!: Columns[];

  hideWhenNouserList: boolean = false;
  noData: boolean = false;
  preLoader: boolean = true;

  constructor(public userServices: UsersDocuments, public toastr: ToastrService) { }

  ngOnInit(): void {
    this.dataState();
    let s = this.userServices.GetUsersList();
    s.snapshotChanges().subscribe(data => {
      this.userList = [];
      data.forEach(item => {
        let getItem: any = item.payload.toJSON(); 
        getItem['key'] = item.key;
        this.userList.push(getItem as Users);
        console.log(getItem['key'])
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
        { id: 15, header: 'Added Documents' },
    ];
    });
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
      this.userServices.DeleteUsers(user.key);
      this.toastr.success(user.fullName + ' successfully deleted!');
    }
  }

}
