import { Component, OnInit } from '@angular/core';
import { AuthService } from '../services-firebase/auth.service';
@Component({
  selector: 'bsd-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss']
})
export class HeaderComponent implements OnInit {
  showNav: boolean = false;

  constructor(public authService: AuthService){
  }

  ngOnInit(): void {
  }
  toggleNav(){
    this.showNav = !this.showNav;
  }
}
