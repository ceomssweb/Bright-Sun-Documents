import { Component, OnInit, OnDestroy} from '@angular/core';
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
  getID!: any;
  hideWhenNouserList: boolean = false;
  noData: boolean = false;
  preLoader: boolean = true;
  chartData: any;
  chartOptions: any;
  payStat: any[] = [];
  datetimes: any[] = [];
  count: string[] = [];

  constructor(
    public authService: AuthService,
    public userServices: UsersDocuments,
    public userApi: UsersDocuments,
    public fb: FormBuilder,
    public toastr: ToastrService

  ) {

  }

  ngOnInit(): void {
    this.userServices.userList = [];
    this.dataState();
    this.userApi.GetUsersList();
    let s = this.userServices.GetUsersList();
    s.snapshotChanges().subscribe(data => {
      data.forEach(item => {
        let getItem: any = item.payload.toJSON(); 
        getItem['key'] = item.key;
        this.getID = item.key;
        this.userServices.userList.push(getItem as Users);
        this.payStat.push(getItem.paymentStatus);
      });
      this.count = this.payStat.reduce((acc, value) => ({
        ...acc,
        [value]: (acc[value] || 0) + 1
     }), {});
     
      this.chartData = {
        labels: Object.keys(this.count),
        datasets: [
            {
                data: Object.values(this.count),
                backgroundColor: [
                    "#42A5F5",
                    "#66BB6A",
                    "#FFA726",
                    "#808080",
                    "#696969"
                ],
                hoverBackgroundColor: [
                    "#64B5F6",
                    "#81C784",
                    "#FFB74D",
                    "#C0C0C0",
                    "#A9A9A9"

                ]
            }
        ]
    };
    });
    this.chartOptions = {
      responsive: false,
      maintainAspectRatio: false,
      
    };
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

  ngOnDestroy(){
    this.userServices.userList = [];
  }
}
