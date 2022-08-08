import { Component, OnInit } from '@angular/core';
import { AuthService } from 'src/app/shared/services-firebase/auth.service';
import { ToastrService } from 'ngx-toastr';
import { UsersDocuments } from '../documents-services/document.sevices';

@Component({
  selector: 'bsd-settings',
  templateUrl: './settings.component.html',
  styleUrls: ['./settings.component.scss']
})
export class SettingsComponent implements OnInit {




  constructor(
    public authService: AuthService,
    public toastr: ToastrService,
    public userService: UsersDocuments

  ) {

  }

  ngOnInit(): void {
  }

}

