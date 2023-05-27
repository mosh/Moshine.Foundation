namespace Moshine.Foundation.Security.Interfaces;

uses
  Moshine.Foundation.Security.ViewModels;

type
  IClaimsRepository = public interface
    method GetClaimsForUserAsync(id:Integer):Task<IEnumerable<ClaimsViewModel>>;
  end;

end.