namespace Moshine.Foundation;

uses
  Foundation;

type

  ProxyException = public class (NSException)
  public
    property Url:String;

    constructor withName(aName: NSExceptionName) reason(aReason: nullable NSString) userInfo(aUserInfo: nullable NSDictionary);
    begin
      inherited constructor withName(aName) reason(aReason) userInfo(aUserInfo);

      self.Url := ''
    end;

    constructor withName(aName: NSExceptionName) reason(aReason: nullable NSString) userInfo(aUserInfo: nullable NSDictionary) FromUrl(aUrl:NSString);
    begin
      inherited constructor withName(aName) reason(aReason) userInfo(aUserInfo);

      self.Url := aUrl;
    end;

  end;

  HttpStatusCodeException = public class(ProxyException)
  public
    property StatusCode:Integer;

    constructor withName(aName: NSExceptionName) reason(aReason: nullable NSString) userInfo(aUserInfo: nullable NSDictionary) StatusCode(aCode:Integer) FromUrl(aUrl:NSString);
    begin
      inherited constructor withName(aName) reason(aReason) userInfo(aUserInfo);

      self.Url := aUrl;
      self.StatusCode := aCode;
    end;

  end;

  AuthenticationRequiredException = public class(ProxyException)
  end;

  MissingAuthTokenException = public class(AuthenticationRequiredException)
  end;


  // No network connection, no local user so unable to proceed
  NoNetworkConnectionException = public class(ProxyException)
  end;

end.
