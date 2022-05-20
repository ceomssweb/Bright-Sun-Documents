import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SendDocumentsComponent } from './send-documents/send-documents.component';
import { SharedModule } from '../shared/shared.module';
import { DocumentRequestRoutingModule } from './document-request-routing.module';
import { DocumentRequestComponent } from './document-request/document-request.component';



@NgModule({
  declarations: [
    SendDocumentsComponent,
    DocumentRequestComponent
  ],
  imports: [
    CommonModule,
    DocumentRequestRoutingModule,
    SharedModule,
  ]
})
export class DocumentRequestModule { }
