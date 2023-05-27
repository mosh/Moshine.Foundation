namespace Moshine.Foundation.Security.Models;


type
  AccessTokenInformation = public class
  public
    property email:String;
    property family_name:String;
    property given_name:String;
    property name:String;
    property error:AccessTokenError;
  end;

end.