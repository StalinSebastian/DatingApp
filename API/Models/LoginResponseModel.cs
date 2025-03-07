using API.Entities;
using Microsoft.AspNetCore.Mvc;

namespace API.Models
{
    public class LoginResponseModel
    {
        public required string Username { get; set; }
        public required DateTime LastActive { get; set; }
        public required string Token { get; set; }

        public static LoginResponseModel FromEntity(AppUser appUser, string token)
        {
            return new LoginResponseModel()
            {
                Username = appUser.UserName,
                LastActive = appUser.LastActive,
                Token = token
            };
        }
    }
}
