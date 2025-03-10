import { Component, inject } from '@angular/core';
import { LoginComponent } from "../login/login.component";
import { FormsModule } from '@angular/forms';
import { AccountService } from '../_services/account.service';

@Component({
  selector: 'app-nav',
  standalone: true,
  imports: [FormsModule, LoginComponent],
  templateUrl: './nav.component.html',
  styleUrl: './nav.component.scss'
})
export class NavComponent {
  accountService = inject(AccountService);
  model: any = {}
  isAuthenticated: any = false;

  login() {
    console.log(this.model);
    this.accountService.login(this.model).subscribe({
      next: response => {
        console.log(response);
        this.isAuthenticated = true;
      },
      error: error => {
        console.log(error);
      }
    })
  }
}
