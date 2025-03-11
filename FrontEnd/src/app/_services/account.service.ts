import { HttpClient } from '@angular/common/http';
import { inject, Injectable, signal } from '@angular/core';
import { environment } from '../../environments/environment.development';
import { User } from '../_models/user';
import { map } from 'rxjs';

@Injectable({
  providedIn: 'root'
})

export class AccountService {
  http = inject(HttpClient);
  apiUrl = environment.serviceApiEndpoint;
  currentUser = signal<User | null>(null);

  login(model: any) {
    return this.http.post<User>(`${this.apiUrl}account/login`, model).pipe(
      map( user => {
        if(user) {
          localStorage.setItem('user', JSON.stringify(user));
          this.currentUser.set(user);
        }
      })
    )
  }

  logout() {
    localStorage.removeItem('user');
    this.currentUser.set(null);
  }

  register(model: any) {
    return this.http.post(`${this.apiUrl}account/register`, model);
  }
}
