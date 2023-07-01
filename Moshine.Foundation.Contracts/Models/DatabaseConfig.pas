namespace Moshine.Foundation.Contracts.Models;

type

  DatabaseConfig = public class
  public
    property Host:String; required;
    property Port:Integer; required;
    property Username:String; required;
  end;

end.