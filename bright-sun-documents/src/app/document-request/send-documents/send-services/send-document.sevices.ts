import { Injectable } from '@angular/core';
import { Users } from './users';
import {
  AngularFireDatabase,
  AngularFireList,
  AngularFireObject,
} from '@angular/fire/compat/database';
import { userInfo } from 'os';
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
      parentName: Users.parentName,
      email: Users.email,
      mobileNumber: Users.mobileNumber,
      docType: Users.docType,
      currentOwnerName: Users.currentOwnerName,
      currentOwnerAddress: Users.currentOwnerAddress,
      currentOwnerAge: Users.currentOwnerAge,
      currentOwnerSex: Users.currentOwnerSex,
      buyerRelationType: Users.buyerRelationType,
      buyerName: Users.buyerName,
      buyerAddress: Users.buyerAddress,
      buyerAge: Users.buyerAge,
      buyerSex: Users.buyerSex,
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
      parentName: Users.parentName,
      email: Users.email,
      mobileNumber: Users.mobileNumber,
      docType: Users.docType,
      currentOwnerName: Users.currentOwnerName,
      currentOwnerAddress: Users.currentOwnerAddress,
      currentOwnerAge: Users.currentOwnerAge,
      currentOwnerSex: Users.currentOwnerSex,
      buyerRelationType: Users.buyerRelationType,
      buyerName: Users.buyerName,
      buyerAddress: Users.buyerAddress,
      buyerAge: Users.buyerAge,
      buyerSex: Users.buyerSex,
      // uploadFiles: Users.uploadFiles,
    });
  }
  // Delete Users Object
  DeleteUsers(id: string, getSP: string) {
    this.UsersRef = this.db.object('Users-list/'+ getSP +'/' + id);
    this.UsersRef.remove();
  }
}