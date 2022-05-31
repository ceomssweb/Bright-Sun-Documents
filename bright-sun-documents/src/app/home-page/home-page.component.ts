import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'bsd-home-page',
  templateUrl: './home-page.component.html',
  styleUrls: ['./home-page.component.scss']
})
export class HomePageComponent implements OnInit {
  constructor() { }
  signInShow: boolean = true;
  ngOnInit(): void {

  }
clickLogIn(){
  this.signInShow = true;
}
clickLogUp(){
  this.signInShow = false;
}
}
