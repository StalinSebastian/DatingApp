using System.Security.Cryptography;
using System.Text;
using API.Data;
using API.Entities;
using API.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace API.Controllers
{
    public class AccountController(DataContext context, ITokenService tokenService) : BaseApiController
    {
        [HttpPost("register")]
        public async Task<ActionResult<RegisterResponseModel>> Register(RegisterRequestModel model)
        {
            if (await UserExists(model.UserName))
            {
                return BadRequest("Username is taken");
            }

            using var hmac = new HMACSHA512();

            var user = new AppUser
            {
                UserName = model.UserName.ToLower(),
                Email = model.Email,
                FirstName = model.FirstName,
                LastName = model.LastName,
                DateOfBirth = model.DateOfBirth,
                Created = DateTime.Now,
                LastActive = DateTime.Now,
                PasswordHash = hmac.ComputeHash(Encoding.UTF8.GetBytes(model.Password)),
                PasswordSalt = hmac.Key
            };

            context.Users.Add(user);
            await context.SaveChangesAsync();

            var token = tokenService.CreateToken(user);

            return RegisterResponseModel.FromEntity(user, token);
        }

        [HttpPost("login")]
        public async Task<ActionResult<LoginResponseModel>> Login(LoginRequestModel model)
        {
            var appUser = await context.Users.FirstOrDefaultAsync(x =>
                                x.UserName.ToLower() == model.Username.ToLower());

            if (appUser == null)
            {
                return Unauthorized("Invalid username or password");
            }

            using var hmac = new HMACSHA512(appUser.PasswordSalt);
            var computeHash = hmac.ComputeHash(Encoding.UTF8.GetBytes(model.Password));
            for (int i = 0; i < computeHash.Length; i++)
            {
                if (computeHash[i] != appUser.PasswordHash[i])
                {
                    return Unauthorized("Invalid username or password");
                }
            }
            appUser.LastActive = DateTime.Now;
            await context.SaveChangesAsync();

            var token = tokenService.CreateToken(appUser);

            return LoginResponseModel.FromEntity(appUser, token);
        }

        private async Task<bool> UserExists(string userName)
        {
            if (await context.Users.AnyAsync(x => x.UserName.ToLower() == userName.ToLower()))
            {
                return true;
            }

            return false;
        }
    }
}
