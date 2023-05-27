namespace Moshine.Foundation.Security;

uses
  Moshine.Foundation.Security.Interfaces,
  Moshine.Foundation.Security.Models,
  Microsoft.Extensions.Logging,
  System.Security.Claims,
  System.Threading.Tasks;

type

  SimplePrincipalProvider = public class(PrincipalProvider,IPrincipalProvider)
  private
    _repository:IUserRepository;
    property logger:ILogger;

  public

    constructor(repository:IUserRepository; claimsRepositoryImpl:IClaimsRepository; loggerImpl:ILogger<IPrincipalProvider>);
    begin
      inherited constructor(claimsRepositoryImpl);

      _repository := repository;
      logger := loggerImpl;
    end;

    method ProvidePrincipalAsync(accessToken:String):Task<MyPrincipal>;
    begin
      var principal:MyPrincipal := nil;

      try

        var user := await _repository.FindAsync(accessToken);

        if(assigned(user))then
        begin
          logger.LogTrace($'Found user for email {user.Email} with id {user.Id}');

          var userIdentity := new ClaimsIdentity(await ClaimsForUserAsync(user), 'iSailed');
          principal := new MyPrincipal(userIdentity);

          logger.LogTrace('assigned principal');
        end
        else
        begin
          logger.LogTrace('No UserInfo for accesstoken');
        end;
      except
        on e:Exception do
          begin
            logger.LogError(e,'Failed getting principal');
            raise;
          end;
      end;

      exit principal;

    end;

  end;

end.