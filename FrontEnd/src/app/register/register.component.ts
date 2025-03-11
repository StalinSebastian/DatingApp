import { Component, inject, OnInit, output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { AccountService } from '../_services/account.service';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './register.component.html',
  styleUrl: './register.component.scss'
})
export class RegisterComponent implements OnInit {
  readonly accountService = inject(AccountService);
  cancelRegister = output<boolean>();
  isAuthenticated: boolean = false;
  model: any = {};

  ngOnInit(): void {
    const currentUser = this.accountService.currentUser();
    this.isAuthenticated = currentUser != null;
  }

  register() {
    console.log(this.model);
    this.accountService.register(this.model).subscribe({
      next: data => {
        console.log(data);
        this.isAuthenticated = true;
      },
      error: error => {
        console.log(error);
      },
      complete: () => {
        console.log('complete');
        this.cancelRegister.emit(false);
      }
    })
  }

  cancel() {
    console.log('cancelled');
    this.cancelRegister.emit(false);
  }
}
