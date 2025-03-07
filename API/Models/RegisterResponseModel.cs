using System;
using API.Entities;
using Microsoft.AspNetCore.Mvc;

namespace API.Models;

public class RegisterResponseModel
{
    public required string UserName { get; set; }
    public required string Email { get; set; }
    public required string FirstName { get; set; }
    public required string LastName { get; set; }
    public required DateTime DateOfBirth { get; set; }
    public required string Token { get; set; }

    internal static ActionResult<RegisterResponseModel> FromEntity(AppUser user, string token)
    {
        return new RegisterResponseModel
        {
            UserName = user.UserName,
            Email = user.Email,
            FirstName = user.FirstName,
            LastName = user.LastName,
            DateOfBirth = user.DateOfBirth,
            Token = token
        };
    }
}
