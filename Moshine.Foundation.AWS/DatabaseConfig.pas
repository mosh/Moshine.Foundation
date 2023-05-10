namespace Moshine.Foundation.AWS;

uses
  Moshine.Foundation.AWS.Interfaces,
  Moshine.Foundation.Contracts.Models;

type

  PostgresDatabaseConfig = public class(DatabaseConfig)
  public
    property Database:String;
    property SearchPath:String;
  end;



end.