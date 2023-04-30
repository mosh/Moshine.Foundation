namespace Moshine.Foundation.AWS;

uses
  Moshine.Foundation.AWS.Interfaces,
  Moshine.Foundation.Contracts.Models;

type

  PostgresDatabaseConfig = public class(IPostgresDatabaseConfig)
  public
    property Host:String;
    property Port:Integer;
    property Username:String;
    property Database:String;
    property SearchPath:String;
  end;



end.