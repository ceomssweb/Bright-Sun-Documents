import { Injectable } from '@angular/core';
import { Users } from './users';
import {
  AngularFireDatabase,
  AngularFireList,
  AngularFireObject,
} from '@angular/fire/compat/database';
import { AuthService } from 'src/app/shared/services-firebase/auth.service';

@Injectable({
  providedIn: 'root',
})
export class UsersDocuments {
  MultiUsersRef!: AngularFireList<any>;
  UsersRef!: AngularFireObject<any>;
  
  constructor(private db: AngularFireDatabase, public ath: AuthService) {}
  // Create Users
  userPath: string = JSON.parse(localStorage.getItem('user')!).uid;
  adminUser: String = 'saravanan039@hotmail.com';
  AddUsers(Users: Users, filename: any) {
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
      paymentStatus: Users.paymentStatus
    });
  }
  GetEmp(email: any){
    // this.empRef = this.db.object('emp-list/');
    // this.empRef.push(email);
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
  // Update Users Object
  UpdateUsers(Users: Users, filename: any) {
    this.UsersRef.update({
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
      paymentStatus: Users.paymentStatus
    });
  }
  // Delete Users Object
  DeleteUsers(id: string) {
    this.UsersRef = this.db.object('Users-list/'+ this.userPath +'/' + id);
    this.UsersRef.remove();
  }
}