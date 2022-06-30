import { Component, OnInit } from '@angular/core';
import { getAuth, createUserWithEmailAndPassword } from "firebase/auth";
import { AuthService } from '../services-firebase/auth.service';

@Component({
  selector: 'bsd-sign-up',
  templateUrl: './sign-up.component.html',
  styleUrls: ['./sign-up.component.scss']
})
export class SignUpComponent implements OnInit {

  file: any;
  constructor(public authService: AuthService) { }

  ngOnInit(): void {
  }

  chooseFile(event: any){
    debugger;
      this.file = event.target.files;
  }

}




