namespace Moshine.Foundation;

uses
  Foundation;

type

  ProxyException = public class (NSException)
  public
    property Url:String;

    method initWithName(aName: NSExceptionName) reason(aReason: nullable NSString) userInfo(aUserInfo: nullable NSDictionary):instancetype; override;
    begin
      self := inherited initWithName(aName) reason(aReason) userInfo(aUserInfo);
      if(assigned(self))then
      begin
        self.Url := '';

      end;
      exit self;
    end;



    method initWithName(name: not nullable NSString) reason(reason:String) userInfo(info:NSDictionary) FromUrl(fromUrl:NSString) :id;
    begin
      self := inherited initWithName(name) reason(reason) userInfo(info);
      if(assigned(self))then
      begin
        self.Url := fromUrl;
      end;

      exit self;

    end;

  end;

  HttpStatusCodeException = public class(ProxyException)
  public
    property StatusCode:Integer;

    method initWithName(name: not nullable NSString) reason(reason:NSString) userInfo(info:NSDictionary) StatusCode(code:Integer) FromUrl(fromUrl:NSString) :id;
    begin
      self := inherited initWithName(name) reason(reason) userInfo(info);
      if(assigned(self))then
      begin
        self.StatusCode := code;
        self.Url := fromUrl;
      end;
      exit self;
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