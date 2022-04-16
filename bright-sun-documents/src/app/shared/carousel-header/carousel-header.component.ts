import { Component, OnInit } from '@angular/core';
@Component({
  selector: 'bsd-carousel-header',
  templateUrl: './carousel-header.component.html',
  styleUrls: ['./carousel-header.component.scss']
})

export class CarouselHeaderComponent {
  imageName = 0;
	constructor() {}
	ngOnInit() {
    this.autoImageSrc();
  }
  autoImageSrc(){
    for(let i = 0; i<=66; i++){
      setTimeout(() => {
        this.imageName= i;
      }, i * 100);
    }
  }
}

