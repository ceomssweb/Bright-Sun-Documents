import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AuthGuard } from './shared/guard/auth.guard';
import { SignUpComponent } from './shared/sign-up/sign-up.component';
import { VerifyEmailComponent } from './shared/verify-email/verify-email.component';
import { ForgotPasswordComponent } from './shared/forgot-password/forgot-password.component';

const routes: Routes = [
  {
    path: '',
    loadChildren: () =>
      import('./document-request/document-request.module').then((m) => m.DocumentRequestModule),
      canActivate: [AuthGuard]
  },
  {
    path: 'home-page',
    loadChildren: () =>
      import('./home-page/home-page.module').then((m) => m.HomePageModule),
  },
  {
    path: 'document-request',
    loadChildren: () =>
      import('./document-request/document-request.module').then(
        (m) => m.DocumentRequestModule
      ),
    canActivate: [AuthGuard]
  },
  { path: 'register-user', component: SignUpComponent },
  { path: 'verify-email-address', component: VerifyEmailComponent },
  { path: 'forgot-password', component: ForgotPasswordComponent },
];
@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
})
export class AppRoutingModule {}
