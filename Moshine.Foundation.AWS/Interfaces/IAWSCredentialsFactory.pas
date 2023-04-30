namespace Moshine.Foundation.AWS.Interfaces;

uses
  Amazon.Runtime;

type
  IAWSCredentialsFactory = public interface
    method Get:AWSCredentials;
  end;

end.