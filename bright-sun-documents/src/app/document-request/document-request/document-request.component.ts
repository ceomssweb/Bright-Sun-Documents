import { Component, EventEmitter, OnInit, Output } from '@angular/core';
import { AngularFireList } from '@angular/fire/compat/database';
import { MenuItem } from 'primeng/api';
import { AuthService } from 'src/app/shared/services-firebase/auth.service';
import { UsersDocuments } from '../documents-services/document.sevices';

@Component({
  selector: 'bsd-document-request',
  templateUrl: './document-request.component.html',
  styleUrls: ['./document-request.component.scss']
})
export class DocumentRequestComponent implements OnInit {
  title = "Welcome to Bright Sun Documents";
  page = 1;
  preLoader: boolean = false;
  noData: boolean = false;
  hideWhenNouserList: boolean = false;
  sendDocShow: boolean = false;
  viewDocShow: boolean = false;
  showDetails: boolean = true;
  showSettings: boolean = false;
  sendReport: boolean = false;
  items!: MenuItem[];
  userEmail: string = JSON.parse(localStorage.getItem('user')!).email;
  getEmp!: any[];
  showEmpDialog: boolean = false;
  showEmpHeader!: string;
  empData: string = '';
  @Output() viewEmpMail = new EventEmitter<string>();
  @Output() viewEmpName = new EventEmitter<string>();

  constructor(public authService: AuthService, public userService: UsersDocuments) { }

  ngOnInit(): void {
    this.items = [
      {label: 'My Profile', icon: 'pi pi-fw pi-id-card', command: () => this.showUserDetails(),},
      {label: 'Add Client', icon: 'pi pi-fw pi-user-plus', command: () => this.showAddNew(),},
      {label: 'View/Edit Client', icon: 'pi pi-fw pi-eye', command: () => this.showView(),},
      {label: 'Report', icon: 'pi pi-fw pi-chart-bar', command: () => this.showReport(),},
      {label: 'Settings', icon: 'pi pi-fw pi-cog', command: () => this.showSetting(),}
    ];
    this.dataState();
    if(this.userEmail == this.userService.adminUser){
    let s = this.authService.GetEmpList();
    s.snapshotChanges().subscribe(data => {
      this.getEmp = [];
      data.forEach(item => {
        let getItem: any = item.payload.toJSON(); 
        if(getItem.mail != this.userService.adminUser){
          this.getEmp.push(getItem);
        }
        
      });
    });
  }

  }
  dataState() {     
    this.authService.GetEmpList().valueChanges().subscribe(data => {
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
  showSetting(){
    this.sendDocShow = false;
    this.viewDocShow = false;
    this.showDetails = false;
    this.sendReport = false;
    this.showSettings = true;
    this.title="Settings"
  }
  showUserDetails(){
    this.sendDocShow = false;
    this.viewDocShow = false;
    this.showDetails = true;
    this.sendReport = false;
    this.showSettings = false;
    this.title="Welcome to Bright Sun Documents"
  }
  showAddNew(){
    this.sendDocShow = true;
    this.viewDocShow = false;
    this.showDetails = false;
    this.sendReport = false;
    this.showSettings = false;
    this.title="Enter Client Details to send Documents"
  }
  showView(){
    this.sendDocShow = false;
    this.viewDocShow = true;
    this.showDetails = false;
    this.sendReport = false;
    this.showSettings = false;
    this.title="View/Edit Client"
  }
  showReport(){
    this.sendDocShow = false;
    this.viewDocShow = false;
    this.showDetails = false;
    this.sendReport = true;
    this.showSettings = false;
    this.title="Overall Report of available Clients"
  }
  showEmpDetails(getUser:any){
    this.showEmpDialog = true;
    this.showEmpHeader = getUser.name;
    this.empData = getUser;
    this.viewEmpMail.emit(this.empData);
    this.viewEmpName.emit(this.showEmpHeader);
  }
  hideEmpDialog(){
    this.showEmpDialog = false;
  }
}
