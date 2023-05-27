namespace Moshine.Foundation.Security;

uses
  Moshine.Foundation.Security.Interfaces,
  Moshine.Foundation.Security.Models, System.Security, System.Security.Claims;

type
  PrincipalProvider = public class
  private
  protected
    property ClaimsRepository:IClaimsRepository;
  public

    constructor(claimsRepositoryImpl:IClaimsRepository);
    begin
      ClaimsRepository := claimsRepositoryImpl;
    end;

    method ClaimsForUserAsync(someUser:User):Task<sequence of Claim>;
    begin
      var claims := new List<Claim>;
      claims.Add(new Claim(MyClaimTypes.Id, someUser.Id.ToString, ClaimValueTypes.String, ClaimValueTypes.String));
      claims.Add(new Claim(ClaimTypes.Email, someUser.Email, ClaimValueTypes.String));

      var additionalClaims := await ClaimsRepository.GetClaimsForUserAsync(someUser.Id);

      for each additionalClaim in additionalClaims do
      begin
        claims.Add(new Claim(additionalClaim.Claim, additionalClaim.Claim));
      end;

      exit claims;

    end;
  end;

end.