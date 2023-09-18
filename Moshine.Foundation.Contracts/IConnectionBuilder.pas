namespace Moshine.Foundation.Contracts;

{$IF ECHOES}

uses
  System.Data.Common, System.Threading;

type

  IConnectionBuilder = public interface
    method BuildAsync(cancellationToken:CancellationToken := default):Task<DbConnection>;
    property IsPostgres:Boolean read;
    method BuildDataSourceAsync(cancellationToken:CancellationToken := default): Task<DbDataSource>;

  end;

{$ENDIF}

end.