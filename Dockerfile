FROM microsoft/dotnet:2.2-aspnetcore-runtime
WORKDIR /app
EXPOSE 80
COPY ./WebApplication/WebApplication/app .
ENTRYPOINT ["dotnet", "WebApplication.dll"]