namespace Moshine.Foundation.AWS;

uses
  System.Threading;

type
  IAWSSecrets = public interface
    method GetSecretAsync(name:String; cancellationToken:CancellationToken := default):Task<IDictionary<String,Object>>;
  end;

end.