namespace Moshine.Foundation.Web;

uses
  {$IF TOFFEE OR DARWIN}
  Foundation,
  {$ELSEIF ECHOES}
  System.Net.Http,
  {$ENDIF}
  Moshine.Foundation,
  RemObjects.Elements.RTL;


type
  {$IF TOFFEE OR DARWIN}
  PlatformHttpRequest = public NSURLRequest;
  PlatformMutableHttpRequest = public NSMutableURLRequest;
  {$ELSEIF ECHOES}
  PlatformHttpRequest = public HttpRequestMessage;
  {$ELSE}
  PlatformHttpRequest = public RemObjects.Elements.RTL.HttpRequest;
  {$ENDIF}

  HttpRequest = public class mapped to PlatformHttpRequest

  public

    {$IFDEF ECHOES}

    constructor (webMethod:String; url:String);
    begin
      var httpMethod := MethodToHttpMethod(webMethod);
      self := new PlatformHttpRequest(httpMethod, url);
    end;

    class method MethodToHttpMethod(webMethod:String):HttpMethod;
    begin
      exit case webMethod of
        'GET': System.Net.Http.HttpMethod.Get;
        'PUT': System.Net.Http.HttpMethod.Put;
        'POST': System.Net.Http.HttpMethod.Post;
        'DELETE': System.Net.Http.HttpMethod.Delete;
        else
          raise new ArgumentException($'Invalid method {webMethod}');
      end;
    end;
    {$ELSEIF TOFFEE OR DARWIN}
    constructor (webMethod:String; urlValue:String);
    begin
      self := new NSMutableURLRequest() withURL( new NSURL() withString( urlValue ));
      self.setHttpMethod(webMethod);
    end;

    {$ELSE}
    constructor (webMethod:String; url:String);
    begin
      self := new PlatformHttpRequest(RemObjects.Elements.RTL.Url.UrlWithString(url), MethodToHttpRequestMode(webMethod));
    end;

    class method MethodToHttpRequestMode(webMethod:String):HttpRequestMode;
    begin
      exit case webMethod of
        'GET': HttpRequestMode.Get;
        'PUT': HttpRequestMode.Put;
        'POST': HttpRequestMode.Post;
        'DELETE': HttpRequestMode.Delete;
        else
          raise new ArgumentException($'Invalid method {webMethod}');
      end;
    end;

    {$ENDIF}

    method AddHeader(name:String; value:String);
    begin
      {$IF TOFFEE OR DARWIN}
      if( mapped is not NSMutableURLRequest)then
      begin
        raise new MoshineFoundationException('mapped is not a NSMutableException');
      end;

      NSMutableURLRequest(mapped).setValue(value) forHTTPHeaderField(name);
      {$ELSEIF ECHOES}
      mapped.Headers.Add(name,value);
      {$ELSE}
      mapped.Headers.Add(name,$' {value}');
      {$ENDIF}

    end;


    property HttpMethod:String write
      begin
        {$IFDEF TOFFEE OR DARWIN}
        if( mapped is not NSMutableURLRequest)then
        begin
          raise new MoshineFoundationException('mapped is not a NSMutableException');
        end;

        NSMutableURLRequest(mapped).setHTTPMethod(value);
        {$ELSEIF ECHOES}
        {$ELSE}
        {$ENDIF}
      end;

    property Url:String read
      begin
        {$IFDEF TOFFEE OR DARWIN}
        exit mapped.URL.path;
        {$ENDIF}

      end;

    property JsonBody : String write
      begin

        {$IFDEF TOFFEE OR DARWIN}
        if( mapped is not NSMutableURLRequest)then
        begin
          raise new MoshineFoundationException('mapped is not a NSMutableException');
        end;

        NSMutableURLRequest(mapped).setValue('application/json; charset=utf-8') forHTTPHeaderField('Content-Type');
        NSMutableURLRequest(mapped).setValue('application/json') forHTTPHeaderField('Accept');
        NSMutableURLRequest(mapped).setValue( $'{value.Length}' ) forHTTPHeaderField('Content-Length');

        var data := NSString(value).dataUsingEncoding(NSStringEncoding.NSUTF8StringEncoding);

        NSMutableURLRequest(mapped).setHTTPBody(data);

        {$ELSEIF ECHOES}
        var content := new StringContent(value, Encoding.UTF8, 'application/json');
        mapped.Content := content;
        {$ELSE}
        mapped.Headers.Add('Content-Type','application/json; charset=utf-8');
        mapped.Content := new HttpBinaryRequestContent(value, Encoding.UTF8);
        {$ENDIF}

      end;

  end;

end.