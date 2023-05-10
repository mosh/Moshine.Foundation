namespace Moshine.Foundation.AWS;

uses
  Amazon.Runtime, Moshine.Foundation.AWS.Interfaces;

type

  LamdaCredentialsFactory = public class(IAWSCredentialsFactory)
  private
    property environment:LambdaEnvironment;
    property credentials:AWSCredentials;
  public

    constructor(environment:LambdaEnvironment);
    begin
      self.environment := environment;
    end;

    method Get: AWSCredentials;
    begin
      if(not assigned(credentials))then
      begin
        credentials := new SessionAWSCredentials(environment.Access.AccessKeyId, environment.Access.SecretAccessKey,environment.Access.SessionToken)
      end;
      exit credentials;
    end;
  end;

end.