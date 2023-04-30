namespace Moshine.Foundation.Contracts.Interfaces;

type

  IDatabaseConfig = public interface
    property Host:String read;
    property Port:Integer read;
    property Username:String read;
  end;


end.