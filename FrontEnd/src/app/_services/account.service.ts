import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { environment } from '../../environments/environment.development';

@Injectable({
  providedIn: 'root'
})

export class AccountService {
  http = inject(HttpClient);
  apiUrl = environment.serviceApiEndpoint;

  login(model: any) {
    return this.http.post(`${this.apiUrl}account/login`, model);
  }

  register(model: any) {
    return this.http.post(`${this.apiUrl}account/register`, model);
  }
}
