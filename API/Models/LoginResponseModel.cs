using API.Entities;
using Microsoft.AspNetCore.Mvc;

namespace API.Models
{
    public class LoginResponseModel
    {
        public string? Username { get; private set; }
        public DateTime? LastActive { get; private set; }
        public string? Token { get; private set; }
        public string? FullName { get; private set; }

        public static LoginResponseModel FromEntity(AppUser appUser, string token)
        {
            return new LoginResponseModel()
            {
                Username = appUser.UserName,
                FullName = $"{appUser.FirstName}" ?? "User",
                LastActive = appUser.LastActive,
                Token = token
            };
        }
    }
}
