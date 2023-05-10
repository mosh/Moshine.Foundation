namespace Moshine.Foundation.AWS;

uses
  Amazon,
  Amazon.SecretsManager,
  Amazon.SecretsManager.Extensions.Caching,
  Microsoft.Extensions.Logging,
  Moshine.Foundation.AWS.Interfaces,
  Newtonsoft.Json,
  System.Dynamic, System.Threading;

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

      var secret := await cache.Value.GetSecretStringAsync(name, cancellationToken).ConfigureAwait(false);

      Logger.LogInformation('Retrieved secret');

      exit IDictionary<String,Object>(JsonConvert.DeserializeObject<ExpandoObject>(secret));

    end;
  end;

end.