import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';

import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
const firebaseConfig = {
  apiKey: "AIzaSyDhl6vjZyG5bDB5MQJ8BSnWi5oUu8gxAXE",
  authDomain: "bright-sun-documents.firebaseapp.com",
  projectId: "bright-sun-documents",
  storageBucket: "bright-sun-documents.appspot.com",
  messagingSenderId: "555788329592",
  appId: "1:555788329592:web:cb18b4f046d6f19947838d",
  measurementId: "G-MDETWJJ8T0"
};

const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    BrowserAnimationsModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})

export class AppModule { }
