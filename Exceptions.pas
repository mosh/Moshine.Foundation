﻿namespace Moshine.Foundation;


{$IF TOFFEE}
uses
  Foundation;
{$ELSE}
{$ENDIF}


type

  {$IF TOFFEE}
  PlatformException = public NSException;
  {$ELSE}
  PlatformException = public System.Exception;
  {$ENDIF}


  ProxyException = public class (PlatformException)
  public
    property Url:String;

    {$IF TOFFEE}
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


    {$IF TOFFEE}
    constructor withName(aName: NSExceptionName) reason(aReason: nullable NSString) userInfo(aUserInfo: nullable NSDictionary) StatusCode(aCode:Integer) FromUrl(aUrl:NSString);
    begin
      inherited constructor withName(aName) reason(aReason) userInfo(aUserInfo);

      self.Url := aUrl;
      self.StatusCode := aCode;
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

end.