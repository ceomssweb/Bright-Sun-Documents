import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';

import { initializeApp } from "firebase/app";
import { getFunctions  } from "firebase/functions";
import { getAnalytics } from "firebase/analytics";
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { SharedModule } from './shared/shared.module';
import { RouterModule } from '@angular/router';
import { HttpClientModule } from '@angular/common/http';

import { AngularFireModule } from '@angular/fire/compat';
import { AngularFireAuthModule } from '@angular/fire/compat/auth';
import { AngularFireStorageModule } from '@angular/fire/compat/storage';
import { AngularFirestoreModule } from '@angular/fire/compat/firestore';
import { AngularFireDatabaseModule } from '@angular/fire/compat/database';
import { AuthService } from './shared/services-firebase/auth.service';
import { FormsModule,ReactiveFormsModule } from '@angular/forms';
import { ToastrModule } from 'ngx-toastr';
import { getStorage } from 'firebase/storage';



export const firebaseConfig = {
  apiKey: "AIzaSyDhl6vjZyG5bDB5MQJ8BSnWi5oUu8gxAXE",
  authDomain: "bright-sun-documents.firebaseapp.com",
  databaseURL: "https://bright-sun-documents-default-rtdb.firebaseio.com",
  projectId: "bright-sun-documents",
  storageBucket: "bright-sun-documents.appspot.com",
  messagingSenderId: "555788329592",
  appId: "1:555788329592:web:cb18b4f046d6f19947838d",
  measurementId: "G-MDETWJJ8T0"
}
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
const storage = getStorage(app);
const functions = getFunctions(app);
@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    BrowserAnimationsModule,
    SharedModule,
    RouterModule,
    HttpClientModule,
    AngularFireModule.initializeApp(firebaseConfig),
    AngularFireAuthModule,
    AngularFirestoreModule,
    AngularFireStorageModule,
    AngularFireDatabaseModule,
    ReactiveFormsModule,
    FormsModule,
    ToastrModule.forRoot({
      positionClass :'toast-bottom-right'
    })
  ],
  providers: [AuthService, Storage],
  bootstrap: [AppComponent]
})

export class AppModule { }
