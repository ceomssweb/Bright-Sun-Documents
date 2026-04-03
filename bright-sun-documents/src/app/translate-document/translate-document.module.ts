import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { TranslateDocumentRoutingModule } from './translate-document-routing.module';
import { TranslateDocumentComponent } from './translate-document/translate-document.component';
import { SharedModule } from '../shared/shared.module';

@NgModule({
  declarations: [
    TranslateDocumentComponent
  ],
  imports: [
    CommonModule,
    FormsModule,
    HttpClientModule,
    TranslateDocumentRoutingModule,
    SharedModule
  ]
})
export class TranslateDocumentModule {}
