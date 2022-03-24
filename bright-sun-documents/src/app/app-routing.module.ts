import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

const routes: Routes = [{ path: 'home-page', loadChildren: () => import('./home-page/home-page.module').then(m => m.HomePageModule) },
{ path: '', loadChildren: () => import('./home-page/home-page.module').then(m => m.HomePageModule) },
{ path: 'courses', loadChildren: () => import('./courses/courses.module').then(m => m.CoursesModule) },
{ path: 'products', loadChildren: () => import('./products/products.module').then(m => m.ProductsModule) },
{ path: 'contact', loadChildren: () => import('./contact/contact.module').then(m => m.ContactModule) }];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
