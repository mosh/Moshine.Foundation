namespace Moshine.Foundation.AWS;

uses
  Amazon,
  Amazon.SecretsManager,
  Amazon.SecretsManager.Model,
  Amazon.SecretsManager.Extensions.Caching,
  Microsoft.Extensions.Logging,
  Moshine.Foundation.AWS.Interfaces,
  System.Dynamic,
  System.IO,
  System.Text,
  System.Text.Json,
  System.Threading;

type

  AWSCachedSecrets = public class(IAWSSecrets)
  private
    property Logger:ILogger<AWSCachedSecrets>;
    property factory:IAWSCredentialsFactory;
    property cache:IAmazonSecretsManager := GetSecretsManager; lazy;
    property SecretRegion:RegionEndpoint;

  public
    constructor(factoryImpl:IAWSCredentialsFactory; region:RegionEndpoint; loggerImpl:ILogger<AWSCachedSecrets>);
    begin
      Logger := loggerImpl;
      factory := factoryImpl;
      SecretRegion := region;

      Logger.LogInformation('AWSCachedSecrets Constructor');

      /*
      cache := new &Lazy<IAmazonSecretsManager>(method
          begin

            var client := new AmazonSecretsManagerClient(SecretRegion);


            Logger.LogInformation('Creating SecretsManagerCache');

            var client := new AmazonSecretsManagerClient(factory.Get, SecretRegion);

            var configuration := new SecretCacheConfiguration();
            configuration.Client := client;
            Logger.LogInformation('Created SecretsManagerCache');

            exit new SecretsManagerCache(client, configuration);

            exit client;

          end,System.Threading.LazyThreadSafetyMode.ExecutionAndPublication);
            */

    end;

    method GetSecretsManager:IAmazonSecretsManager;
    begin
      var client := new AmazonSecretsManagerClient(SecretRegion);
      exit client;
    end;

    method GetSecretAsync(name:String; cancellationToken:CancellationToken := default):Task<IDictionary<String,Object>>;
    begin
      Logger.LogInformation('About to retrieve secret');

      var request := new GetSecretValueRequest
      (
          SecretId := name,
      );

      var response := await cache.GetSecretValueAsync(request).ConfigureAwait(false);
      var secretString := response.SecretString;

      /*
      var request := new GetSecretValueRequest
      (
          SecretId := name,
      );

      var response := await client.GetSecretValueAsync(request).ConfigureAwait(false);
      var secretString := response.SecretString;

      var request := new GetSecretValueRequest(SecretId := name);

      var response := await cache.GetSecretValueAsync(request).ConfigureAwait(false);
      var secretString := response.SecretString;
      */

      Logger.LogInformation('Retrieved secret');

      using jsonStream := new MemoryStream(Encoding.UTF8.GetBytes(secretString)) do
      begin
        var secret := await JsonSerializer.DeserializeAsync<ExpandoObject>(jsonStream);

        exit IDictionary<String,Object>(secret);

      end;


    end;
  end;

end.
