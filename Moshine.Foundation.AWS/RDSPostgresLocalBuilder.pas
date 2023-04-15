namespace Moshine.Foundation.AWS;

uses
  Amazon,
  Amazon.RDS.Util,
  Amazon.Runtime.CredentialManagement,
  Moshine.Foundation, Npgsql;

type
  RDSPostgresLocalBuilder = public class(IConnectionBuilder)
  private
    property generator:IAWSTokenGenerator;
    property databaseConfig:IPostgresDatabaseConfig;
  public

    constructor(generator:IAWSTokenGenerator; databaseConfig:IPostgresDatabaseConfig);
    begin
      self.generator := generator;
      self.databaseConfig := databaseConfig;
    end;

    method Build: System.Data.Common.DbConnection;
    begin

      var token := generator.Generate(databaseConfig.Host, databaseConfig.Port, databaseConfig.Username);

      var builder := new NpgsqlConnectionStringBuilder;

      builder.Host := databaseConfig.Host;
      builder.Username := databaseConfig.Username;
      builder.Password := token;
      builder.Database := databaseConfig.Database;
      builder.SearchPath := databaseConfig.SearchPath;
      builder.SslMode := SslMode.Require;
      builder.TrustServerCertificate := true;
      builder.Port := databaseConfig.Port;

      exit new NpgsqlConnection(builder.ToString)

    end;

  end;
end.