import { Component, OnInit } from '@angular/core';
import { AuthService } from 'src/app/shared/services-firebase/auth.service';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'bsd-settings',
  templateUrl: './settings.component.html',
  styleUrls: ['./settings.component.scss']
})
export class SettingsComponent implements OnInit {




  constructor(
    public authService: AuthService,
    public toastr: ToastrService,

  ) {

  }

  ngOnInit(): void {
  }

}

