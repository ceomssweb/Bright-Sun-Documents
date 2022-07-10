import { Component, Input, OnInit } from '@angular/core';
import { AngularFireList } from '@angular/fire/compat/database';
import { MenuItem } from 'primeng/api';
import { AuthService } from 'src/app/shared/services-firebase/auth.service';
import { UsersDocuments } from '../../documents-services/document.sevices';

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

  @Input() mailKey = '';

  constructor(public authService: AuthService, public userService: UsersDocuments) { }

  ngOnInit(): void {
    
  }

}
