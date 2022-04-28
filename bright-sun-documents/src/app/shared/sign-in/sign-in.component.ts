import { Component, OnInit } from '@angular/core';
import { getAuth, signInWithEmailAndPassword } from "firebase/auth";

@Component({
  selector: 'bsd-sign-in',
  templateUrl: './sign-in.component.html',
  styleUrls: ['./sign-in.component.scss']
})
export class SignInComponent implements OnInit {
  userEmail:string = '';
  userPassword:string = '';

  constructor() { }

  ngOnInit(): void {
  }


  onSignIn(){
    debugger;
    const auth = getAuth();
    const email = this.userEmail;
    const password = this.userPassword;
    signInWithEmailAndPassword(auth, email, password)
    .then((userCredential) => {
      //console.log("Signed In");
    })
    .catch((error) => {
      const errorCode = error.code;
      const errorMessage = error.message;
      console.log(errorCode, errorMessage);
      alert(errorMessage + " Please check the credentials for valid email id and correct password.");
    });
  }






}




