namespace Moshine.Foundation.AWS;

uses
  System.Threading;

type
  IPostgresConfigBuilder = public interface
    method GetConfigAsync(cancellationToken:CancellationToken := default):Task<PostgresDatabaseConfig>;
  end;

end.