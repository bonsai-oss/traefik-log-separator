FROM mcr.microsoft.com/dotnet/runtime:6.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["traefik-log-separator.csproj", "./"]
RUN dotnet restore "traefik-log-separator.csproj"
COPY . .
WORKDIR "/src/"
RUN dotnet build "traefik-log-separator.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "traefik-log-separator.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "traefik-log-separator.dll"]
