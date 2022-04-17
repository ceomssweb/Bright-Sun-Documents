import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'bsd-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss']
})
export class HeaderComponent implements OnInit {
  showNav = false;
  constructor(){
  }

  ngOnInit(): void {
  }
  toggleNav(){
    this.showNav = !this.showNav;
  }

}
