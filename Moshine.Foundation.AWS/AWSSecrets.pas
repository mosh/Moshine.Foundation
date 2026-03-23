namespace Moshine.Foundation.AWS;

uses
  Amazon,
  Amazon.SecretsManager,
  Amazon.SecretsManager.Model,
  Moshine.Foundation.AWS.Interfaces,
  System.Text.Json,
  System.Dynamic,
  System.IO,
  System.Net,
  System.Text,
  System.Threading;

type


  AWSSecrets = public class(IAWSSecrets)
  private
    property factory:IAWSCredentialsFactory;
    property region:RegionEndpoint;

  public

    constructor(factoryImpl:IAWSCredentialsFactory; regionImpl:RegionEndpoint);
    begin
      self.region := regionImpl;
      self.factory := factoryImpl;
    end;

    method GetSecretAsync(secretName:String; cancellationToken:CancellationToken := default):Task<IDictionary<String,Object>>;
    begin

      var client := new AmazonSecretsManagerClient(factory.Get, region);

      var request := new GetSecretValueRequest(SecretId := secretName, VersionStage := 'AWSCURRENT');

      var response := await client.GetSecretValueAsync(request, cancellationToken).ConfigureAwait(false);

      if response.HttpStatusCode <> HttpStatusCode.OK then
      begin
        raise new ApplicationException($'Failed to get secret StatusCode {response.HttpStatusCode}');
      end;

      var secretString := response.SecretString;

      using jsonStream := new MemoryStream(Encoding.UTF8.GetBytes(secretString)) do
      begin
        var secret := await JsonSerializer.DeserializeAsync<ExpandoObject>(jsonStream);

        exit IDictionary<String,Object>(secret);

      end;

    end;

  end;

end.