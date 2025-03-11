import { Component, inject, OnInit } from '@angular/core';
import { RegisterComponent } from "../register/register.component";
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment.development';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [RegisterComponent],
  templateUrl: './home.component.html',
  styleUrl: './home.component.scss'
})
export class HomeComponent implements OnInit {
  registerMode: any;
  http = inject(HttpClient);
  users: any;

  ngOnInit(): void {
    this.getUsers()
  }

  private getUsers() {
    this.http.get(`${environment.serviceApiEndpoint}users`).subscribe({
      next: usersList => {
        this.users = usersList;
        console.log(usersList);
      },
      error: err => console.error(err),
      complete: () => console.log('GetUsers API Complete')
    });
  }
}
