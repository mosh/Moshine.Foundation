namespace Moshine.Foundation.Data.SqlServer;

uses
  Microsoft.Data.SqlClient,
  Moshine.Foundation.Contracts, System.Data.Common, System.Threading;

type

  SqlServerConnectionBuilder = public class(IConnectionBuilder)
    private
      builder:SqlConnectionStringBuilder;
    public
      constructor(builderImpl:SqlConnectionStringBuilder);
      begin
        builder := builderImpl;
        IsPostgres := false;
      end;

      method BuildAsync(cancellationToken:CancellationToken := default):Task<DbConnection>;
      begin
        exit Task.FromResult(DbConnection(new SqlConnection(builder.ToString)));
      end;

      property IsPostgres:Boolean read;

      method BuildDataSourceAsync(cancellationToken:CancellationToken := default): Task<DbDataSource>;
      begin

      end;

  end;

end.