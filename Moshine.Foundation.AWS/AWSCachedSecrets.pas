namespace Moshine.Foundation.AWS;

uses
  Amazon,
  Amazon.SecretsManager,
  Amazon.SecretsManager.Extensions.Caching,
  Microsoft.Extensions.Logging,
  Moshine.Foundation.AWS.Interfaces, Newtonsoft.Json, System.Dynamic;

type
  AWSCachedSecrets = public class(IAWSSecrets)
  private
    property Logger:ILogger<AWSCachedSecrets>;
    property factory:IAWSCredentialsFactory;
    property cache:&Lazy<SecretsManagerCache>;
    property region:RegionEndpoint;

  public
    constructor(factoryImpl:IAWSCredentialsFactory; region:RegionEndpoint; loggerImpl:ILogger<AWSCachedSecrets>);
    begin
      Logger := loggerImpl;
      factory := factoryImpl;
      self.region := region;

      cache := new &Lazy<SecretsManagerCache>(method
          begin
            Logger.LogTrace('Creating SecretsManagerCache');
            var client := new AmazonSecretsManagerClient(factory.Get, region);
            var configuration := new SecretCacheConfiguration();
            Logger.LogTrace('Created SecretsManagerCache');

            exit new SecretsManagerCache(client, configuration);

          end,System.Threading.LazyThreadSafetyMode.ExecutionAndPublication);
    end;

    method GetSecretAsync(name:String):Task<IDictionary<String,Object>>;
    begin
      Logger.LogTrace('About to retrieve secret');

      var secret := await cache.Value.GetSecretString(name).ConfigureAwait(false);

      Logger.LogTrace('Retrieved secret');

      exit IDictionary<String,Object>(JsonConvert.DeserializeObject<ExpandoObject>(secret));

    end;
  end;

end.