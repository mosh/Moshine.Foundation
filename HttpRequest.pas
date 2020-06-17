﻿namespace Moshine.Foundation.Web;

uses
  {$IF TOFFEE}
  Foundation,
  {$ELSEIF ECHOES}
  System.Net.Http,
  {$ENDIF}
  RemObjects.Elements.RTL;


type
  {$IF TOFFEE}
  PlatformHttpRequest = public NSMutableURLRequest;
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
    {$ELSEIF TOFFEE}
    constructor (webMethod:String; url:String);
    begin
      self := new NSMutableURLRequest() withURL( new NSURL() withString( url ));
      self.setHttpMethod(webMethod);
    end;

    {$ELSE}
    constructor (webMethod:String; url:String);
    begin
      self := new PlatformHttpRequest(RemObjects.Elements.RTL.Url.UrlWithString(url), MethodToHttpMethod(webMethod));
    end;

    class method MethodToHttpMethod(webMethod:String):HttpRequestMode;
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
      {$IF TOFFEE}
      mapped.setValue(value) forHTTPHeaderField(name);
      {$ELSEIF ECHOES}
      mapped.Headers.Add(name,value);
      {$ENDIF}

    end;


    property HttpMethod:String write
      begin
        {$IFDEF TOFFEE}
        mapped.setHTTPMethod(value);
        {$ENDIF}

        {$IFDEF ECHOES}
        {$ENDIF}
      end;

    property JsonBody : String write
      begin

        {$IFDEF TOFFEE}
        mapped.setValue('application/json; charset=utf-8') forHTTPHeaderField('Content-Type');
        mapped.setValue('application/json') forHTTPHeaderField('Accept');
        mapped.setValue( $'{value.Length}' ) forHTTPHeaderField('Content-Length');

        var data := NSString(value).dataUsingEncoding(NSStringEncoding.NSUTF8StringEncoding);

        mapped.setHTTPBody(data);

        {$ENDIF}

        {$IFDEF ECHOES}
        var content := new StringContent(value, Encoding.UTF8, 'application/json');
        mapped.Content := content;
        {$ENDIF}


      end;

  end;

end.