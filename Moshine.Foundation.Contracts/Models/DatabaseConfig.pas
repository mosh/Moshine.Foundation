namespace Moshine.Foundation.Contracts.Models;

type
  IDatabaseConfig = public interface
    property Host:String;
    property Port:Integer;
    property Username:String;
  end;


  DatabaseConfig = public class(IDatabaseConfig)
  public
    property Host:String;
    property Port:Integer;
    property Username:String;
  end;

end.