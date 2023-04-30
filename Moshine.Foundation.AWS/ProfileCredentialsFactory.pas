namespace Moshine.Foundation.AWS;

uses
  Amazon.Runtime,
  Amazon.Runtime.CredentialManagement,
  Microsoft.Extensions.Logging,
  Moshine.Foundation.AWS.Interfaces;

type


  ProfileCredentialsFactory = public class(IAWSCredentialsFactory)
  private
    property credentials:AWSCredentials;
    property profile:String;
    property logger:ILogger;
  public

    constructor(profile:String; loggerImpl:ILogger);
    begin
      self.profile := profile;
      logger := loggerImpl;
    end;

    method Get: AWSCredentials;
    begin
      if(not assigned(credentials))then
      begin

        logger.LogTrace('Getting credentials');

        var sharedFile := new SharedCredentialsFile;

        if sharedFile.TryGetProfile(profile,out var basicProfile) then
        begin
          if AWSCredentialsFactory.TryGetAWSCredentials(basicProfile, sharedFile, out var awsCredentials) then
          begin
            credentials := awsCredentials;
          end
          else
          begin
            raise new ApplicationException('Failed to get credentials');
          end;
        end
        else
        begin
          raise new ApplicationException($'Failed to get profile {profile}');
        end;
      end;

      exit credentials;
    end;
  end;

end.