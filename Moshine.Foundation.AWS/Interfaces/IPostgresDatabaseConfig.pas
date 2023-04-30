namespace Moshine.Foundation.AWS.Interfaces;


uses
  Moshine.Foundation.Contracts.Interfaces,
  Moshine.Foundation.AWS.Interfaces;

type
  IPostgresDatabaseConfig = public interface(IDatabaseConfig)
    property SearchPath:String read;
    property Database:String read;
  end;


end.