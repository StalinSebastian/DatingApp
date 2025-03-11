import { HttpClient } from '@angular/common/http';
import { Component, inject, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { NavComponent } from "./nav/nav.component";
import { User } from './_models/user';
import { AccountService } from './_services/account.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, NavComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent implements OnInit {

  http = inject(HttpClient);
  accountService = inject(AccountService);

  title = 'Dating App';
  users: any;

  ngOnInit(): void {
    this.getUsers();
    this.setCurrentUser();
  }

  setCurrentUser() {
    const userString = localStorage.getItem('user');

    if(!userString) return;
    let user = JSON.parse(userString);

    console.log(user);

    this.accountService.currentUser.set(user);
  }

  private getUsers() {
    this.http.get(`https://localhost:5001/api/users`).subscribe({
      next: usersList => {
        this.users = usersList;
        console.log(usersList);
      },
      error: err => console.error(err),
      complete: () => console.log('GetUsers API Complete')
    });
  }
}
