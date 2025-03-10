# This stage is used when running from VS in fast mode (Default for Debug configuration)
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 5000
EXPOSE 5001

# Stage 1: Build the API
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
#ARG BUILD_CONFIGURATION=Debug

WORKDIR /src

COPY Directory.Build.props .
COPY Directory.Packages.props .
COPY nuget.config .

# Copy the API project file and restore dependencies
COPY API/API.csproj API/
RUN dotnet restore "API/API.csproj"

COPY API/. API/
WORKDIR "/src/API"
RUN dotnet build "./API.csproj" -c Debug -o /app/build

# Copy the rest of the API source code and publish the app
#COPY API/. API/
FROM build AS publish
#ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./API.csproj" -c Release -o /app/publish

# Stage 2: Create the runtime image
#FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

#ENTRYPOINT ["dotnet", "API.dll"]
ENTRYPOINT ["tail", "-f", "/dev/null"]