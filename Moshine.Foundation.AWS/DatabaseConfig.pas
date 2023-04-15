namespace Moshine.Foundation.AWS;

uses
  Moshine.Foundation.Contracts.Models;

type

  IPostgresDatabaseConfig = public interface(IDatabaseConfig)
    property SearchPath:String;
    property Database:String;
  end;

  PostgresDatabaseConfig = public class(IPostgresDatabaseConfig)
  public
    property Host:String;
    property Port:Integer;
    property Username:String;
    property Database:String;
    property SearchPath:String;
  end;



end.