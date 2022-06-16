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
  AddUsers(Users: Users, getFilNames: any, filename: any) {
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
      selectedDocuments: getFilNames,
      originalNames: filename
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
  // Update Users Object
  UpdateUsers(Users: Users, getFilNames: any, filename: any) {
    debugger;
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
      selectedDocuments: getFilNames,
      originalNames: filename
    });
  }
  // Delete Users Object
  DeleteUsers(id: string) {
    this.UsersRef = this.db.object('Users-list/'+ this.userPath +'/' + id);
    this.UsersRef.remove();
  }
}