namespace Moshine.Foundation.AWS;

uses
  Amazon,
  Amazon.RDS.Util, Amazon.Runtime, Moshine.Foundation.AWS.Interfaces;

type

  IAWSTokenGenerator = public interface
    method Generate(hostname:String; port:Integer;username:String):String;
  end;


  AWSTokenGenerator = public class(IAWSTokenGenerator)

  private
    property factory:IAWSCredentialsFactory;
    property region:RegionEndpoint;
  public

    constructor(factory:IAWSCredentialsFactory; region:RegionEndpoint);
    begin
      self.region := region;
      self.factory := factory;
    end;

    method Generate(hostname:String; port:Integer;username:String):String;
    begin
      exit RDSAuthTokenGenerator.GenerateAuthToken(factory.Get, region,hostname, port, username);
    end;

  end;

end.