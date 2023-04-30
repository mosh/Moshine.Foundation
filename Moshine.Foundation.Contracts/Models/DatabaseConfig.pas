namespace Moshine.Foundation.Contracts.Models;

uses
  Moshine.Foundation.Contracts.Interfaces;

type

  DatabaseConfig = public class(IDatabaseConfig)
  public
    property Host:String;
    property Port:Integer;
    property Username:String;
  end;

end.