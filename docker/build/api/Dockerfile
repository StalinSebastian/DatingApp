# Stage 1: Build the API
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

WORKDIR /src

# Copy project files first to cache dependencies
COPY ["Directory.Build.props", "."]
COPY ["Directory.Packages.props", "."]
COPY ["nuget.config", "."]
# Copy the API project file and restore dependencies
COPY ["API/API.csproj", "API/"]
RUN dotnet restore "API/API.csproj"

# Copy the rest of the API source code
COPY API/. API/
#COPY . .

WORKDIR "/src/API"
RUN dotnet build "API.csproj" -c Release -o /app/build

# Publish the app
FROM build AS publish
RUN dotnet publish "API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Run migrations before switching to runtime image
RUN dotnet tool restore
RUN dotnet ef database update -v

# Stage 2: Create the runtime image
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Copy published files
COPY --from=publish /app/publish .

# Ensure SQLite directory exists and set correct permissions
RUN mkdir -p /app/data && chmod -R 777 /app/data

# Copy database if needed
COPY --from=publish /app/publish/Dating.db /app/data/Dating.db

# Copy SSL certificates
COPY docker/certs/localhost.pem /etc/certs/localhost.pem
COPY docker/certs/localhost-key.pem /etc/certs/localhost-key.pem

# Expose ports
EXPOSE 5000
EXPOSE 5001

# Environment variables
ENV ASPNETCORE_URLS="https://+:5001;http://+:5000"
ENV ASPNETCORE_Kestrel__Certificates__Default__Path=/etc/certs/localhost.pem
ENV ASPNETCORE_Kestrel__Certificates__Default__KeyPath=/etc/certs/localhost-key.pem

# Run migrations and start the app
ENTRYPOINT ["sh", "-c", "dotnet API.dll"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]
