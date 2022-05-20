import { Component, OnInit } from '@angular/core';
import { AuthService } from 'src/app/shared/services-firebase/auth.service';

@Component({
  selector: 'bsd-send-documents',
  templateUrl: './send-documents.component.html',
  styleUrls: ['./send-documents.component.scss']
})
export class SendDocumentsComponent implements OnInit {

  constructor(public authService: AuthService) { }

  ngOnInit(): void {
  }

}
