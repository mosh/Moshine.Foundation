namespace Moshine.Foundation.AWS;

uses
  Amazon,
  Microsoft.Extensions.Logging,
  Moshine.Foundation.AWS.Models;

type

  LambdaEnvironment = public class
  private
    property Logger:ILogger;
  public

    property Access:AWSSecurityAccess read;

    property Region:RegionEndpoint read
      begin
        var defaultRegionValue := Environment.GetEnvironmentVariable(AWSEnvironmentVariables.DefaultRegion);
        var regionValue := Environment.GetEnvironmentVariable(AWSEnvironmentVariables.Region);

        if(not String.IsNullOrEmpty(regionValue))then
        begin
          exit RegionEndpoint.GetBySystemName(regionValue);
        end;

        if(not String.IsNullOrEmpty(defaultRegionValue))then
        begin
          exit RegionEndpoint.GetBySystemName(defaultRegionValue);
        end;
      end;

    constructor(loggerImpl:ILogger);
    begin

      Logger := loggerImpl;

      var accessKey := Environment.GetEnvironmentVariable(AWSEnvironmentVariables.AccessKey);
      var accessKeyId := Environment.GetEnvironmentVariable(AWSEnvironmentVariables.AccessKeyId);
      var secretAccessKey := Environment.GetEnvironmentVariable(AWSEnvironmentVariables.SecretAccessKey);
      var sessionToken := Environment.GetEnvironmentVariable(AWSEnvironmentVariables.SessionToken);


      Access := new AWSSecurityAccess;
      Access.SecretAccessKey := secretAccessKey;
      Access.AccessKeyId := accessKeyId;
      Access.SessionToken := sessionToken;

      if String.IsNullOrEmpty(accessKey) then
      begin
        Logger.LogInformation('accessKey is empty');
      end;

      if String.IsNullOrEmpty(accessKeyId) then
      begin
        Logger.LogInformation('accessKeyId is empty');
      end;

      if String.IsNullOrEmpty(secretAccessKey) then
      begin
        Logger.LogInformation('secretAccessKey is empty');
      end;

      if String.IsNullOrEmpty(sessionToken) then
      begin
        Logger.LogInformation('sessionToken is empty');
      end;

    end;
  end;

end.