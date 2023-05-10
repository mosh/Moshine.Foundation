namespace Moshine.Foundation;

{$IF ECHOES}

uses
  System.Data.Common, System.Threading;

type
  IConnectionBuilder = public interface
    method BuildAsync(cancellationToken:CancellationToken := default):Task<DbConnection>;
    property IsPostgres:Boolean read;
  end;

{$ENDIF}

end.