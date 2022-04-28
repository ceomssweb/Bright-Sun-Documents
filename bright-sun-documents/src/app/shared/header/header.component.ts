import { Component, OnInit } from '@angular/core';
import { getAuth, signOut } from 'firebase/auth';
@Component({
  selector: 'bsd-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss']
})
export class HeaderComponent implements OnInit {
  showNav: boolean = false;
  showSignIn: boolean = false;
  showSignUp: boolean = false;
  constructor(){
  }

  ngOnInit(): void {
  }
  toggleNav(){
    this.showNav = !this.showNav;
  }
  openSignIn(){
    this.showSignIn = true;
  }
  openSignUp(){
    this.showSignUp = true;
  }
  signOut(){
    const auth = getAuth();
    signOut(auth)
      .then(() => {
        //console.log("Sign Out")
      })
      .catch((err) => {
        console.log(err.message)
      })
  }
}
