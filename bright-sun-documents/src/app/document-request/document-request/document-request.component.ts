import { Component, OnInit } from '@angular/core';
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
  sendReport: boolean = false;
  items!: MenuItem[];

  constructor(public authService: AuthService, public userService: UsersDocuments) { }

  ngOnInit(): void {
    this.items = [
      {label: 'My Profile', icon: 'pi pi-fw pi-home', command: () => this.showUserDetails(),},
      {label: 'Add Client', icon: 'pi pi-fw pi-plus', command: () => this.showAddNew(),},
      {label: 'View/Edit Client', icon: 'pi pi-fw pi-eye', command: () => this.showView(),},
      {label: 'Report', icon: 'pi pi-fw pi-bolt', command: () => this.showReport(),}
    ];
  }
  showUserDetails(){
    this.sendDocShow = false;
    this.viewDocShow = false;
    this.showDetails = true;
    this.sendReport = false;
    this.title="Welcome to Bright Sun Documents"
  }
  showAddNew(){
    this.sendDocShow = true;
    this.viewDocShow = false;
    this.showDetails = false;
    this.sendReport = false;
    this.title="Enter Client Details to send Documents"
  }
  showView(){
    this.sendDocShow = false;
    this.viewDocShow = true;
    this.showDetails = false;
    this.sendReport = false;
    this.title="View/Edit Client"
  }
  showReport(){
    this.sendDocShow = false;
    this.viewDocShow = false;
    this.showDetails = false;
    this.sendReport = true;
    this.title="Overall Report of available Clients"
  }
}
