import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { SendDocumentsComponent } from './send-documents/send-documents.component';
import { SharedModule } from '../shared/shared.module';
import { DocumentRequestRoutingModule } from './document-request-routing.module';
import { DocumentRequestComponent } from './document-request/document-request.component';
import { FileUploadModule } from 'primeng/fileupload';
import { HttpClientModule } from '@angular/common/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { DropdownModule } from 'primeng/dropdown';
import { InputTextModule } from 'primeng/inputtext';
import { ViewDocumentsComponent } from './view-documents/view-documents.component';
import { MenuModule } from 'primeng/menu';
import {TableModule} from 'primeng/table';
import { NgxPaginationModule } from 'ngx-pagination';
import {DialogModule} from 'primeng/dialog';
import {ProgressBarModule} from 'primeng/progressbar';
import {ToastModule} from 'primeng/toast';
import { ReportDocumentsComponent } from './report-documents/report-documents.component';
import {ChartModule} from 'primeng/chart';
import { ViewEmpComponent } from './document-request/view-emp/view-emp.component';

@NgModule({
  declarations: [
    DocumentRequestComponent,
    SendDocumentsComponent,
    ViewDocumentsComponent,
    ReportDocumentsComponent,
    ViewEmpComponent
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
    InputTextModule,
    MenuModule,
    TableModule,
    NgxPaginationModule,
    DialogModule,
    ProgressBarModule,
    ToastModule,
    ChartModule
  ]
})
export class DocumentRequestModule { }

