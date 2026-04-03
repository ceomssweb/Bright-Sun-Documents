import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { TranslateDocumentComponent } from './translate-document/translate-document.component';

const routes: Routes = [{ path: '', component: TranslateDocumentComponent }];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class TranslateDocumentRoutingModule {}
