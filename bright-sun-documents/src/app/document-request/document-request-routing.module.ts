import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { DocumentRequestComponent } from './document-request/document-request.component';

const routes: Routes = [{ path: '', component: DocumentRequestComponent }];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class DocumentRequestRoutingModule { }
