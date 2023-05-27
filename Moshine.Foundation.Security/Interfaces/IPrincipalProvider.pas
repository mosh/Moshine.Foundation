namespace Moshine.Foundation.Security.Interfaces;

uses
  Moshine.Foundation.Security.Models,
  System.Threading.Tasks;

type
  IPrincipalProvider = public interface
    method ProvidePrincipalAsync(accessToken:String):Task<MyPrincipal>;
  end;

end.