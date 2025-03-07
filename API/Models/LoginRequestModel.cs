using System.ComponentModel.DataAnnotations;

namespace API.Models
{
    public class LoginRequestModel
    {
        [MaxLength(50)]
        public required string Username { get; set; }
        [MinLength(3), MaxLength(12)]
        public required string Password { get; set; }
    }
}
