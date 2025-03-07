using System.ComponentModel.DataAnnotations;

namespace API.Models
{
    public class RegisterRequestModel
    {
        [MaxLength(50)]
        public required string UserName { get; set; }
        [EmailAddress]
        public required string Email { get; set; }
        [MaxLength(100)]
        public required string FirstName { get; set; }
        [MaxLength(100)]
        public required string LastName { get; set; }
        [DataType(DataType.Date)]
        public required DateTime DateOfBirth { get; set; }
        [MinLength(3), MaxLength(12)]
        public required string Password { get; set; }
    }
}
