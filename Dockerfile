FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["traefik-log-separator.csproj", "./"]
RUN dotnet restore "traefik-log-separator.csproj"
COPY . .
WORKDIR "/src/"
#RUN dotnet build "traefik-log-separator.csproj" -c Release -o /app/build
RUN dotnet publish "traefik-log-separator.csproj" -c Release -o /app/publish

FROM debian:stable-slim as final
RUN apt update && apt install -y libicu67
RUN apt-get autoclean -y && rm -rf /var/lib/apt/lists/*

FROM final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["/app/traefik-log-separator","-i","/log/access.log","-o","/log/output/"]
