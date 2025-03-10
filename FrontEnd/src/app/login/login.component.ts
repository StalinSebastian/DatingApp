import { HttpClient } from '@angular/common/http';
import { Component, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { environment } from '../../environments/environment.development';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.scss'
})
export class LoginComponent {
  http = inject(HttpClient);
  apiUrl = environment.serviceApiEndpoint;
  loginInfo: any = {
    username: '',
    password: ''
  }
  loginError: string = '';
  loginResponse: any = { token: '' };
  loginSuccess: boolean = false;

  login() {
    this.http
      .post(`${this.apiUrl}account/login`, this.loginInfo)
      .subscribe({
        next: (res) => {
          console.log(res)
          this.loginResponse = res;
          this.loginSuccess = this.loginResponse.token.Length > 0
        },
        error: (err) => { console.log(err) },
        complete: () => { console.log('complete') }
      })
  }
}
