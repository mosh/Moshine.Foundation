namespace Moshine.Foundation.AWS;

uses
  Amazon,
  Amazon.RDS.Util, Amazon.Runtime;

type

  IAWSTokenGenerator = public interface
    method Generate(hostname:String; port:Integer;username:String):String;
  end;


  AWSTokenGenerator = public class(IAWSTokenGenerator)

  private
    property credentials:AWSCredentials;
    property region:RegionEndpoint;
  public

    constructor(credentials:AWSCredentials; region:RegionEndpoint);
    begin
      self.region := region;
      self.credentials := credentials;
    end;

    method Generate(hostname:String; port:Integer;username:String):String;
    begin
      exit RDSAuthTokenGenerator.GenerateAuthToken(credentials, region,hostname, port, username);
    end;

  end;

end.