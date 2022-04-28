import { Component, OnInit } from '@angular/core';
import { getAuth, createUserWithEmailAndPassword } from "firebase/auth";

@Component({
  selector: 'bsd-sign-up',
  templateUrl: './sign-up.component.html',
  styleUrls: ['./sign-up.component.scss']
})
export class SignUpComponent implements OnInit {
  userEmail:string = '';
  userPassword:string = '';
  rePassword:string = '';

  constructor() { }

  ngOnInit(): void {
  }


  onSignUp(){
    const auth = getAuth();
    const email = this.userEmail;
    const password = this.userPassword;
    createUserWithEmailAndPassword(auth, email, password)
    .then((userCredential) => {
      //console.log("User Created");
    })
    .catch((error) => {
      const errorCode = error.code;
      const errorMessage = error.message;
      console.log(errorCode, errorMessage);
      alert(" Please check the credentials for valid email id and correct password.");
    });
  }






}




