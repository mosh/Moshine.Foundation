namespace Moshine.Foundation;

{$IF ECHOES}

uses
  System.Data.Common;

type
  IConnectionBuilder = public interface
    method Build:DbConnection;
  end;

{$ENDIF}

end.