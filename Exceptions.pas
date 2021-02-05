namespace Moshine.Foundation;


{$IF TOFFEE}
uses
  Foundation;
{$ELSE}
{$ENDIF}


type

  {$IF COCOA}
  MoshineFoundationException = public NSException;
  {$ELSE}
  MoshineFoundationException = public System.Exception;
  {$ENDIF}


  ProxyException = public class (MoshineFoundationException)
  public
    property Url:String;

    {$IF COCOA}
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
    {$ENDIF}

  end;

  HttpStatusCodeException = public class(ProxyException)
  public
    property StatusCode:Integer;


    {$IF COCOA}
    constructor withName(aName: NSExceptionName) reason(aReason: nullable NSString) userInfo(aUserInfo: nullable NSDictionary) StatusCode(aCode:Integer) FromUrl(aUrl:NSString);
    begin
      inherited constructor withName(aName) reason(aReason) userInfo(aUserInfo);

      self.Url := aUrl;
      self.StatusCode := aCode;
    end;
    {$ELSE}
    constructor(aStatusCode:Integer);
    begin
      inherited constructor('');
      self.StatusCode := aStatusCode;
    end;
    {$ENDIF}


  end;

  AuthenticationRequiredException = public class(ProxyException)
  end;

  MissingAuthTokenException = public class(AuthenticationRequiredException)
  end;


  // No network connection, no local user so unable to proceed
  NoNetworkConnectionException = public class(ProxyException)
  end;


  ProxyFormatException = public class(ProxyException)
  end;

end.