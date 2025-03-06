using System;
using API.Entities;
using Microsoft.EntityFrameworkCore;

namespace API.Data;

/// <summary>
/// Represents the database context for the Dating App application.
/// This class provides access to the database and manages entity mappings.
/// </summary>
/// <remarks>
/// Inherits from DbContext to provide database connectivity and ORM functionality.
/// </remarks>
public class DataContext(DbContextOptions options) : DbContext(options)
{
    /// <summary>
    /// Gets or sets the collection of application users in the database.
    /// </summary>
    /// <remarks>
    /// This DbSet represents the Users table in the database and provides
    /// access to query and manipulate user data.
    /// </remarks>
    public DbSet<AppUser> Users { get; set; }
}
