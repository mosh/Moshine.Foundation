namespace Moshine.Foundation.Security.Models;

uses
  Moshine.Foundation.Security.Models,
  System.Security.Claims,
  System.Security.Principal;

type

  MyPrincipal = public class(ClaimsPrincipal)

  public
    constructor(identity: System.Security.Principal.IIdentity);
    begin
      inherited constructor(identity);
    end;

    property Email:String read
      begin
        exit FindFirst(ClaimTypes.Email).Value;
      end;

    property FullName:String read
      begin
        exit FindFirst(ClaimTypes.Name).Value;
      end;

    property Id:Integer read
      begin
        var claim := FindFirst(MyClaimTypes.Id);
        exit Convert.ToInt32(claim.Value);
      end;

    property UserName:String read
      begin
        var claim := FindFirst(MyClaimTypes.UserName);
        exit claim.Value;
      end;


  end;

end.