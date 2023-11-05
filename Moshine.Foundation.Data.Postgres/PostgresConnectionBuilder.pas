namespace Moshine.Foundation.Data.Postgres;

uses
  Moshine.Foundation.Contracts,
  Npgsql,
  System.Data.Common,
  System.Threading;

type
  PostgresConnectionBuilder = public class(IConnectionBuilder)
  private
    builder:NpgsqlConnectionStringBuilder;
  public

    constructor(builderImpl:NpgsqlConnectionStringBuilder);
    begin
      builder := builderImpl;
      IsPostgres := true;
    end;

    method BuildAsync(cancellationToken:CancellationToken := default):Task<DbConnection>;
    begin
      exit Task.FromResult(DbConnection(new NpgsqlConnection(builder.ToString)));
    end;

    property IsPostgres:Boolean read;

    method BuildDataSourceAsync(cancellationToken:CancellationToken := default): Task<DbDataSource>;
    begin

    end;

  end;
end.