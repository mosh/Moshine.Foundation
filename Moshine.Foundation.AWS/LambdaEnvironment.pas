namespace Moshine.Foundation.AWS;

uses
  Microsoft.Extensions.Logging,
  Moshine.Foundation.AWS.Models;

type

  LambdaEnvironment = public class
  public

    property Access:AWSSecurityAccess read;

    constructor(loggerImpl:ILogger);
    begin
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
        Console.WriteLine('accessKey is empty');
      end;

      if String.IsNullOrEmpty(accessKeyId) then
      begin
        Console.WriteLine('accessKeyId is empty');
      end;

      if String.IsNullOrEmpty(secretAccessKey) then
      begin
        Console.WriteLine('secretAccessKey is empty');
      end;

      if String.IsNullOrEmpty(sessionToken) then
      begin
        Console.WriteLine('sessionToken is empty');
      end;


    end;
  end;

end.