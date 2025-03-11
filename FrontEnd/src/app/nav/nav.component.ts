import { Component, inject, OnInit } from '@angular/core';
//import { LoginComponent } from "../login/login.component";
import { FormsModule } from '@angular/forms';
import { AccountService } from '../_services/account.service';
import { BsDropdownModule } from 'ngx-bootstrap/dropdown';

@Component({
  selector: 'app-nav',
  standalone: true,
  imports: [FormsModule,
    //LoginComponent,
    BsDropdownModule
  ],
  templateUrl: './nav.component.html',
  styleUrl: './nav.component.scss'
})
export class NavComponent implements OnInit {

  accountService = inject(AccountService);
  model: any = { username: '', fullName: '' }
  isAuthenticated: boolean = false;
  userFullName: string = '';

  ngOnInit(): void {
    const currentUser = this.accountService.currentUser();
    this.isAuthenticated = currentUser != null;
    this.userFullName = currentUser?.fullName ?? 'User';
  }

  login() {
    console.log(this.model);
    this.accountService.login(this.model).subscribe({
      next: (response: any) => {
        console.log(response);
        this.isAuthenticated = this.accountService.currentUser() != null;
        this.model.fullName = response.fullName;
      },
      error: error => {
        console.log(error);
      }
    })
  }

  logout() {
    this.accountService.logout();
    this.isAuthenticated = false;
  }
}
