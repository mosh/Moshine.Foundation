namespace Moshine.Foundation.AWS;

uses
  Amazon,
  Amazon.SecretsManager,
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
    property cache:&Lazy<SecretsManagerCache>;
    property SecretRegion:RegionEndpoint;

  public
    constructor(factoryImpl:IAWSCredentialsFactory; region:RegionEndpoint; loggerImpl:ILogger<AWSCachedSecrets>);
    begin
      Logger := loggerImpl;
      factory := factoryImpl;
      SecretRegion := region;

      Logger.LogInformation('AWSCachedSecrets Constructor');

      cache := new &Lazy<SecretsManagerCache>(method
          begin
            Logger.LogInformation('Creating SecretsManagerCache');
            var client := new AmazonSecretsManagerClient(factory.Get, SecretRegion);
            var configuration := new SecretCacheConfiguration();
            configuration.Client := client;
            Logger.LogInformation('Created SecretsManagerCache');

            exit new SecretsManagerCache(client, configuration);

          end,System.Threading.LazyThreadSafetyMode.ExecutionAndPublication);
    end;

    method GetSecretAsync(name:String; cancellationToken:CancellationToken := default):Task<IDictionary<String,Object>>;
    begin
      Logger.LogInformation('About to retrieve secret');

      var secretString := await cache.Value.GetSecretStringAsync(name, cancellationToken).ConfigureAwait(false);

      Logger.LogInformation('Retrieved secret');

      using jsonStream := new MemoryStream(Encoding.UTF8.GetBytes(secretString)) do
      begin
        var secret := await JsonSerializer.DeserializeAsync<ExpandoObject>(jsonStream);

        exit IDictionary<String,Object>(secret);

      end;


    end;
  end;

end.