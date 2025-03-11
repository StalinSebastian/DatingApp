# Stage 1: Build the API
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

WORKDIR /src

COPY ["Directory.Build.props", "."]
COPY ["Directory.Packages.props", "."]
COPY ["nuget.config", "."]
# Copy the API project file and restore dependencies
COPY ["API/API.csproj", "API/"]
RUN dotnet restore "API/API.csproj"

# Copy the rest of the API source code
#COPY API/. API/
COPY . .
WORKDIR "/src/API"
RUN dotnet build "API.csproj" -c Release -o /app/build

# Publish the app
FROM build AS publish
RUN dotnet publish "API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Ensure SQLite directory /app/data exists
RUN mkdir -p /app/data && chmod -R 777 /app/data
COPY API/Dating.db /app/data

RUN dotnet tool restore
RUN dotnet ef database update

# Stage 2: Create the runtime image
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app
COPY --from=publish /app/publish .


# Copy certificates
COPY docker/certs/localhost.pem /etc/certs/localhost.pem
COPY docker/certs/localhost-key.pem /etc/certs/localhost-key.pem

EXPOSE 5000
EXPOSE 5001
ENV ASPNETCORE_URLS="https://+:5001;http://+:5000"
ENV ASPNETCORE_Kestrel__Certificates__Default__Path=/etc/certs/localhost.pem
ENV ASPNETCORE_Kestrel__Certificates__Default__KeyPath=/etc/certs/localhost-key.pem

ENTRYPOINT ["dotnet", "API.dll"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]
