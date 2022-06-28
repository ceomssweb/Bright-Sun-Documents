import { Component, OnInit } from '@angular/core';
import { AuthService } from 'src/app/shared/services-firebase/auth.service';
import { UsersDocuments } from '../documents-services/document.sevices';
import { Columns, Users } from '../documents-services/users';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ToastrService } from 'ngx-toastr';
import { ref, uploadBytesResumable, getDownloadURL, getStorage } from "@angular/fire/storage";

@Component({
  selector: 'bsd-report-documents',
  templateUrl: './report-documents.component.html',
  styleUrls: ['./report-documents.component.scss']
})
export class ReportDocumentsComponent implements OnInit {
  page: number = 1;
  userList: any[] = [];
  getID!: any;
  hideWhenNouserList: boolean = false;
  noData: boolean = false;
  preLoader: boolean = true;

  constructor(
    public authService: AuthService,
    public userServices: UsersDocuments,
    public userApi: UsersDocuments,
    public fb: FormBuilder,
    public toastr: ToastrService,

  ) {

  }

  ngOnInit(): void {
    this.dataState();
    this.userApi.GetUsersList();
    let s = this.userServices.GetUsersList();
    s.snapshotChanges().subscribe(data => {
      this.userList = [];
      data.forEach(item => {
        let getItem: any = item.payload.toJSON(); 
        getItem['key'] = item.key;
        this.getID = item.key;
        this.userList.push(getItem as Users);
      });
    })
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
