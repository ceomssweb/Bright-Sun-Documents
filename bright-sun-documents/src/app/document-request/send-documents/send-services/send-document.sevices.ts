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
  servicePro!: string;
  
  constructor(private db: AngularFireDatabase, public ath: AuthService) {}
  // Create Users
  AddUsers(Users: Users) {
    this.MultiUsersRef.push({
      firstName: Users.fullName,
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
      uploadFiles: Users.uploadFiles,
    });
  }
  // Fetch Single Users Object
  GetUsers(id: string, getSP: string) {
    this.UsersRef = this.db.object('Users-list/'+ getSP +'/' + id);
    return this.UsersRef;
  }
  // Fetch Users List
  GetUsersList(getSP: string) {
    this.MultiUsersRef = this.db.list('Users-list/'+ getSP +'/');
    return this.MultiUsersRef;
  }
  // Update Users Object
  UpdateUsers(Users: Users) {
    this.UsersRef.update({
      firstName: Users.fullName,
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
      uploadFiles: Users.uploadFiles,
    });
  }
  // Delete Users Object
  DeleteUsers(id: string, getSP: string) {
    this.UsersRef = this.db.object('Users-list/'+ getSP +'/' + id);
    this.UsersRef.remove();
  }
}