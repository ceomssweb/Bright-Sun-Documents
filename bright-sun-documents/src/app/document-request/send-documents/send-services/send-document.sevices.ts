import { Injectable } from '@angular/core';
import { Users } from './users';
import {
  AngularFireDatabase,
  AngularFireList,
  AngularFireObject,
} from '@angular/fire/compat/database';
@Injectable({
  providedIn: 'root',
})
export class UsersDocuments {
  MultiUsersRef!: AngularFireList<any>;
  UsersRef!: AngularFireObject<any>;
  constructor(private db: AngularFireDatabase) {}
  // Create Users
  AddUsers(Users: Users) {
    this.MultiUsersRef.push({
      firstName: Users.firstName,
      lastName: Users.lastName,
      email: Users.email,
      mobileNumber: Users.mobileNumber,
    });
  }
  // Fetch Single Users Object
  GetUsers(id: string) {
    this.UsersRef = this.db.object('Users-list/' + id);
    return this.UsersRef;
  }
  // Fetch Users List
  GetUsersList() {
    this.MultiUsersRef = this.db.list('Users-list');
    return this.MultiUsersRef;
  }
  // Update Users Object
  UpdateUsers(Users: Users) {
    this.UsersRef.update({
      firstName: Users.firstName,
      lastName: Users.lastName,
      email: Users.email,
      mobileNumber: Users.mobileNumber,
    });
  }
  // Delete Users Object
  DeleteUsers(id: string) {
    this.UsersRef = this.db.object('Users-list/' + id);
    this.UsersRef.remove();
  }
}