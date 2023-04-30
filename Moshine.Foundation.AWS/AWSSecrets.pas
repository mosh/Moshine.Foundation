namespace Moshine.Foundation.AWS;

uses
  Amazon,
  Amazon.SecretsManager,
  Amazon.SecretsManager.Model,
  Moshine.Foundation.AWS.Interfaces,
  Newtonsoft.Json, System.Dynamic, System.Net;

type


  AWSSecrets = public class(IAWSSecrets)
  private
    property factory:IAWSCredentialsFactory;
    property region:RegionEndpoint;

  public

    constructor(factory:IAWSCredentialsFactory; region:RegionEndpoint);
    begin
      self.region := region;
      self.factory := factory;
    end;

    method GetSecretAsync(secretName:String):Task<IDictionary<String,Object>>;
    begin

      var client := new AmazonSecretsManagerClient(factory.Get, region);

      var request := new GetSecretValueRequest(SecretId := secretName, VersionStage := 'AWSCURRENT');

      var response := await client.GetSecretValueAsync(request).ConfigureAwait(false);

      if response.HttpStatusCode <> HttpStatusCode.OK then
      begin
        raise new ApplicationException($'Failed to get secret StatusCode {response.HttpStatusCode}');
      end;

      var secret := response.SecretString;

      exit IDictionary<String,Object>(JsonConvert.DeserializeObject<ExpandoObject>(secret));


    end;

  end;

end.