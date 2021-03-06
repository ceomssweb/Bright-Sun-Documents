import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SendDocumentsComponent } from './send-documents/send-documents.component';
import { SharedModule } from '../shared/shared.module';
import { DocumentRequestRoutingModule } from './document-request-routing.module';
import { DocumentRequestComponent } from './document-request/document-request.component';
import { FileUploadModule } from 'primeng/fileupload';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import {DropdownModule} from 'primeng/dropdown';
import {InputTextModule} from 'primeng/inputtext';

@NgModule({
  declarations: [
    DocumentRequestComponent,
    SendDocumentsComponent
  ],
  imports: [
    CommonModule,
    DocumentRequestRoutingModule,
    SharedModule,
    FileUploadModule,
    HttpClientModule,
    ReactiveFormsModule,
    FormsModule,
    DropdownModule,
    InputTextModule
  ]
})
export class DocumentRequestModule { }

