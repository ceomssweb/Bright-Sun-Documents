import { Component, Input, OnInit } from '@angular/core';
import { AngularFireList } from '@angular/fire/compat/database';
import { FormBuilder } from '@angular/forms';
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
  cols!: Columns[];
  getID: any;
  fileNames: any[] = [];
  @Input() mailKey = '';
  @Input() nameKey = '';

  constructor(
    public authService: AuthService, 
    public userServices: UsersDocuments,
    public fb: FormBuilder,
    public toastr: ToastrService
    ) { }

  ngOnInit(): void {
    this.dataState();
    this.userServices.userList = [];
    let s = this.userServices.GetEmpList();
    s.snapshotChanges().subscribe(data => {
      data.forEach(item => {
        let getItem: any = item.payload.toJSON(); 
        getItem['key'] = item.key;
        this.getID = item.key;
        this.userServices.userList.push(getItem as Users);
        this.fileNames.push(getItem.originalNames);
      });
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

}
