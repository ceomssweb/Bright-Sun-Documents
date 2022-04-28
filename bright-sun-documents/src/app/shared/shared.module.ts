import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HeaderComponent } from './header/header.component';
import { FooterComponent } from '../shared/footer/footer.component';
import { LayoutComponent } from './layout/layout.component';
import { RouterModule } from '@angular/router';
import { CarouselHeaderComponent } from './carousel-header/carousel-header.component';
import {CarouselModule} from 'primeng/carousel';
import {DialogModule} from 'primeng/dialog';
import { SignInComponent } from './sign-in/sign-in.component';
import { FormsModule } from '@angular/forms';
import { SignUpComponent } from './sign-up/sign-up.component';

@NgModule({
  declarations: [
    HeaderComponent,
    FooterComponent,
    LayoutComponent,
    CarouselHeaderComponent,
    SignInComponent,
    SignUpComponent
  ],
  imports: [
    CommonModule,
    RouterModule,
    CarouselModule,
    DialogModule,
    FormsModule
  ],
  exports: [
    HeaderComponent,
    FooterComponent,
    LayoutComponent,
    CarouselHeaderComponent,
    SignInComponent,
    SignUpComponent
  ]
})
export class SharedModule { }
