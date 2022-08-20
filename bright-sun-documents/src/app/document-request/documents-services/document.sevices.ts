import { Injectable } from '@angular/core';
import { Users } from './users';
import {
  AngularFireDatabase,
  AngularFireList,
  AngularFireObject,
} from '@angular/fire/compat/database';
import { AuthService } from 'src/app/shared/services-firebase/auth.service';
import { ToastrService } from 'ngx-toastr';

@Injectable({
  providedIn: 'root',
})
export class UsersDocuments {
  MultiUsersRef!: AngularFireList<any>;
  UsersRef!: AngularFireObject<any>;
  userList!: Users[];
  
  constructor(private db: AngularFireDatabase, public ath: AuthService, public toastr: ToastrService) {}
  // Create Users
  userPath: string = JSON.parse(localStorage.getItem('user')!).uid;
  adminUser: String = 'saravanan039@hotmail.com';
  AddUsers(Users: Users, filename: any, finalDocStatus: any) {
    this.MultiUsersRef.push({
      fullName: Users.fullName,
      fatherName: Users.fatherName,
      email: Users.email,
      mobileNumber: Users.mobileNumber,
      selectedDoc: Users.selectedDoc,
      currentOwnerName: Users.currentOwnerName,
      currentOwnerAddress: Users.currentOwnerAddress,
      currentOwnerAge: Users.currentOwnerAge,
      currentOwnergender: Users.currentOwnergender,
      selectBuyerRelation: Users.selectBuyerRelation,
      buyerName: Users.buyerName,
      buyerAddress: Users.buyerAddress,
      buyerAge: Users.buyerAge,
      selectedBuyGender: Users.selectedBuyGender,
      originalNames: filename,
      paymentStatus: Users.paymentStatus,
      finalDocStatus: finalDocStatus
    });
  }
  // Fetch Single Users Object
  GetUsers(id: string) {
    this.UsersRef = this.db.object('Users-list/'+ this.userPath +'/' + id);
    return this.UsersRef;
  }
  // Fetch Users List
  GetUsersList() {
    this.MultiUsersRef = this.db.list('Users-list/' + this.userPath);
    return this.MultiUsersRef;
  }
  GetEmpList(){
    this.MultiUsersRef = this.db.list('Users-list/' + this.userPath);
    return this.MultiUsersRef;
  }
  GetPerEmp(empRow:any){
    this.MultiUsersRef = this.db.list('Users-list/' + empRow + '/');
    return this.MultiUsersRef;
  }
  UploadDoc(empKey:any, user:any, filename: any){
    this.UsersRef = this.db.object('Users-list/'+ empKey + '/' + user.key +'/');
    this.UsersRef.update({
      finalDocStatus: filename
    });
    this.toastr.success(
      'Process completed successfully'
   );
  }
  // Update Users Object
  UpdateUsers(Users: Users, filename: any) {
    this.UsersRef.update({
      fullName: Users.fullName,
      fatherName: Users.fatherName,
      email: Users.email,
      selectedDoc: Users.selectedDoc,
      currentOwnerName: Users.currentOwnerName,
      currentOwnerAddress: Users.currentOwnerAddress,
      currentOwnerAge: Users.currentOwnerAge,
      currentOwnergender: Users.currentOwnergender,
      selectBuyerRelation: Users.selectBuyerRelation,
      buyerName: Users.buyerName,
      buyerAddress: Users.buyerAddress,
      buyerAge: Users.buyerAge,
      selectedBuyGender: Users.selectedBuyGender,
      originalNames: filename,
      paymentStatus: Users.paymentStatus
    });
  }
  // Delete Users Object
  DeleteUsers(id: string) {
    this.UsersRef = this.db.object('Users-list/'+ this.userPath +'/' + id);
    this.UsersRef.remove();
  }
}