using API.Extensions;

var builder = WebApplication.CreateBuilder(args);

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddApplicationServices(builder.Configuration);
builder.Services.AddIdentityServices(builder.Configuration);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
    app.MapOpenApi();
    app.UseSwaggerUI();
    app.UseSwagger();
}

app.UseCors(opt => opt
                .AllowAnyHeader()
                .AllowAnyMethod()
                .WithOrigins("https://datingapp-api.azurewebsites.net",
                             "https://datingapp-api.scm.azurewebsites.net",
                             "http://datingapp-frontend.azurewebsites.net",
                             "https://datingapp-frontend.azurewebsites.net",
                             "https://localhost:5001",
                             "http://localhost:5000",
                             "https://localhost:4200",
                             "https://localhost:3000",
                             "http://localhost:3000")
                );

// Remove this line since Azure handles HTTPS externally
// app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

await app.RunAsync();
