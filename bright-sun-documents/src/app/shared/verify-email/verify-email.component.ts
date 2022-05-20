import { Component, OnInit } from '@angular/core';
import { AuthService } from '../services-firebase/auth.service';

@Component({
  selector: 'bsd-verify-email',
  templateUrl: './verify-email.component.html',
  styleUrls: ['./verify-email.component.scss']
})
export class VerifyEmailComponent implements OnInit {

  constructor(public authService: AuthService) { }

  ngOnInit(): void {
  }

}
