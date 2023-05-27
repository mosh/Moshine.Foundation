namespace Moshine.Foundation.Security;


uses
  Microsoft.Extensions.Logging,
  Moshine.Foundation.Security.Interfaces,
  Moshine.Foundation.Security.Models,
  Moshine.Foundation.Security.Proxies,
  System.Collections.Generic,
  System.Security.Claims,
  System.Threading.Tasks;

type

  GoogleAuthPrincipalProvider = public class(PrincipalProvider,IPrincipalProvider)
  private
    property Logger:ILogger;

    _repository:IUserRepository;
    _proxy:GoogleOAuthProxy;


  public

    constructor(repository:IUserRepository; claimsRepositoryImpl:IClaimsRepository; loggerImpl:ILogger<IPrincipalProvider>);
    begin

      inherited constructor(claimsRepositoryImpl);

      _repository := repository;
      Logger := loggerImpl;
      _proxy := new GoogleOAuthProxy(Logger);
      ClaimsRepository := claimsRepositoryImpl;
    end;

    method ProvidePrincipalAsync(accessToken:String):Task<MyPrincipal>;
    begin
      var principal:MyPrincipal := nil;

      try
        var info := await _proxy.GetUserInfoAsync(accessToken).ConfigureAwait(false);


        if(assigned(info))then
        begin
          var someUser := await _repository.FindAsync(info.Email);

          if(not assigned(someUser))then
          begin
            Logger.LogTrace($'Adding user for email {info.Email}');

            someUser := new User;

            someUser.Firstname := info.GivenName;
            someUser.Lastname := info.FamilyName;
            someUser.Email := info.Email;
            var createdUser := await _repository.AddAsync(someUser);
            someUser.Id := createdUser.Id;

          end
          else
          begin
            Logger.LogTrace($'Found user for email {someUser.Email} with id {someUser.Id}');
          end;

          var userIdentity := new ClaimsIdentity(await ClaimsForUserAsync(someUser), 'iSailed');
          principal := new MyPrincipal(userIdentity);

          Logger.LogTrace('Returning principal');

        end
        else
        begin
          Logger.LogTrace('No UserInfo for accesstoken');
        end;
      except
        on e:Exception do
          begin
            Logger.LogError(e,'Failed getting principal');
          end;
      end;

      exit principal;

    end;

  end;

end.