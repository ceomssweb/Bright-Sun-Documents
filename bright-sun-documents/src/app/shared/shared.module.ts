import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HeaderComponent } from './header/header.component';
import { FooterComponent } from '../shared/footer/footer.component';
import { LayoutComponent } from './layout/layout.component';
import { RouterModule } from '@angular/router';
import { CarouselHeaderComponent } from './carousel-header/carousel-header.component';
import {CarouselModule} from 'primeng/carousel';

@NgModule({
  declarations: [
    HeaderComponent,
    FooterComponent,
    LayoutComponent,
    CarouselHeaderComponent
  ],
  imports: [
    CommonModule,
    RouterModule,
    CarouselModule
  ],
  exports: [
    HeaderComponent,
    FooterComponent,
    LayoutComponent,
    CarouselHeaderComponent
  ]
})
export class SharedModule { }
