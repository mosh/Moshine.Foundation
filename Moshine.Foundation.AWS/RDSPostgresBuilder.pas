namespace Moshine.Foundation.AWS;

uses
  Amazon,
  Amazon.RDS.Util,
  Amazon.Runtime.CredentialManagement,
  Moshine.Foundation,
  Moshine.Foundation.AWS.Interfaces,
  Npgsql, System.Data.Common, System.Threading;

type

  RDSPostgresBuilder = public class(IConnectionBuilder)
  private
    property Generator:IAWSTokenGenerator;
    property ConfigBuilder:IPostgresConfigBuilder;
  public

    constructor(generatorImpl:IAWSTokenGenerator; configBuilderImpl:IPostgresConfigBuilder);
    begin
      Generator := generatorImpl;
      ConfigBuilder := configBuilderImpl;
    end;

    method BuildAsync(cancellationToken:CancellationToken := default): Task<DbConnection>;
    begin


      var config := await ConfigBuilder.GetConfigAsync(cancellationToken);

      var token := Generator.Generate(config.Host, config.Port, config.Username);

      var builder := new NpgsqlConnectionStringBuilder;

      builder.Host := config.Host;
      builder.Username := config.Username;
      builder.Password := token;
      builder.Database := config.Database;
      builder.SearchPath := config.SearchPath;
      builder.SslMode := SslMode.Require;
      builder.TrustServerCertificate := true;
      builder.Port := config.Port;

      exit new NpgsqlConnection(builder.ToString)

    end;

    property IsPostgres:Boolean read
      begin
        exit true;
      end;

  end;
end.