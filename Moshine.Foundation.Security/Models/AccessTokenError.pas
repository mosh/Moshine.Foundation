namespace Moshine.Foundation.Security.Models;

type
  AccessTokenError = public class
  public
    property code:Integer;
    property message:String;
    property status:String;
  end;

end.