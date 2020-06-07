﻿namespace Moshine.Foundation.Web;

uses
  {$IF TOFFEE}
  Foundation,
  {$ELSE}
  Newtonsoft.Json,
  System.Net.Http,
  {$ENDIF}
  Moshine.Foundation,
  RemObjects.Elements.RTL;

type


  RequestBuilderDelegate = public block(url:String;webMethod:String;addAuthentication:Boolean):HttpRequest;


  WebProxy = public class

  private
    const UnknownHttpStatusCode = 0;
  protected

    _requestBuilder:RequestBuilderDelegate;

    method WebRequestAs<T>(webMethod:String; url:String;addAuthentication:Boolean := true):T;
    begin
      {$IFDEF TOFFEE}
      exit WebRequestAsObject(webMethod,url,addAuthentication) as T;
      {$ELSE}
      exit JsonConvert.DeserializeObject<T>(WebRequestAsString(webMethod, url, nil,addAuthentication));
      {$ENDIF}
    end;

    method WebRequestAsObject(webMethod:String; url:String;addAuthentication:Boolean := true):Object;
    begin
      exit WebRequestAsObject(webMethod, url, nil,addAuthentication);
    end;

    {$IF TOFFEE}
    method WebRequestAs<T>(webMethod:String; url:String; jsonBody:NSData;addAuthentication:Boolean := true):T;
    begin
      var obj := WebRequestAsObject(webMethod, url, jsonBody,addAuthentication);
      if(not assigned(obj))then
      begin
        exit nil;
      end;
      if (not assigned(T(obj))) then
      begin
        raise new ProxyException withName('ProxyException') reason($'proxy response is not of the correct type ') userInfo(nil) FromUrl(url);
      end;
      exit obj as T;
    end;
    {$ENDIF}

    {$IF TOFFEE}

    method WebRequestAsString(webMethod:String; url:String; jsonBody:NSData;addAuthentication:Boolean := true):String;
    begin
      NSLog('WebRequest Method %@ Url %@',webMethod,url);

      var stringResponse:String := nil;

      var request:HttpRequest;

      if(assigned(_requestBuilder))then
      begin
        request := _requestBuilder(url,webMethod,addAuthentication);
      end
      else
      begin
        request := new HttpRequest(webMethod, url);
        request.HttpMethod := webMethod;
      end;


      if(assigned(jsonBody))then
      begin
        var stringForData := new NSString withData(jsonBody) encoding(NSStringEncoding.NSUTF8StringEncoding);
        request.JsonBody := stringForData;
      end;

      var errorReason:NSString := nil;
      var httpStatusCode:NSInteger := 0;

      var outerExecutionBlock: NSBlockOperation := NSBlockOperation.blockOperationWithBlock(method() begin

        var semaphore := dispatch_semaphore_create(0);

        var session := NSURLSession.sharedSession; // or create your own session with your own NSURLSessionConfiguration

        var task := session.dataTaskWithRequest(request) completionHandler(method (data:NSData; response:NSURLResponse; error:NSError)
          begin

            if(not assigned(error))then
            begin
              NSLog('WebRequest Method %@ Url %@ returned Response',webMethod,url);

              if(response is NSHTTPURLResponse)then
              begin
                var httpResponse := response as NSHTTPURLResponse;

                httpStatusCode := httpResponse.statusCode;

                NSLog('UrlResponse Method %@ Url %@ Response %ld',webMethod,url,httpStatusCode);

                if(httpStatusCode <> 200)then
                begin
                  errorReason := NSString.stringWithFormat('Url  %@ returned Invalid Status Code %ld', url, httpStatusCode);
                end;

              end;

              if(String.IsNullOrEmpty(errorReason))then
              begin
                stringResponse := new NSString withData(data) encoding(NSStringEncoding.NSUTF8StringEncoding);
              end;
            end
            else
            begin
              case error.domain of
                NSURLErrorDomain:
                  begin
                    case error.code of
                      NSURLErrorCannotConnectToHost:
                        httpStatusCode := 503;
                    end;
                  end;
              end;
              errorReason := error.localizedDescription;
            end;

            dispatch_semaphore_signal(semaphore);
          end);

          task.resume;

          dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

        end);

      var workerQueue := new NSOperationQueue;
      workerQueue.addOperations([outerExecutionBlock]) waitUntilFinished(true);

      if(not String.IsNullOrEmpty(errorReason))then
      begin

        case httpStatusCode of
          UnknownHttpStatusCode :
            begin
              raise new ProxyException withName('ProxyException') reason(errorReason) userInfo(nil) FromUrl(url);
            end;
          401:
            begin
              raise new AuthenticationRequiredException withName('AuthenticationRequired') reason('authentication required from 401 statusCode') userInfo(nil) FromUrl(url);
            end;
          503:
            begin
              raise new HttpStatusCodeException withName('ProxyException') reason('Service Unavailable') userInfo(nil) FromUrl(url);
            end;
          else
            begin
              raise new HttpStatusCodeException withName('ProxyException') reason(errorReason) userinfo(nil) StatusCode(httpStatusCode) FromUrl(url);
            end;
        end;

      end;

      exit stringResponse;

    end;


    method WebRequestAsObject(webMethod:String; url:String; jsonBody:NSData;addAuthentication:Boolean := true):Object;
    begin

      var stringResponse := WebRequestAsString(webMethod, url, jsonBody, addAuthentication);

      if (not String.IsNullOrEmpty(stringResponse)) then
      begin
        var data := NSString(stringResponse).dataUsingEncoding(NSStringEncoding.NSUTF8StringEncoding);
        var jsonError:NSError;

        var blockData := NSJSONSerialization.JSONObjectWithData(data) options(NSJSONReadingOptions.NSJSONReadingMutableContainers ) error( var jsonError );

        if(assigned(jsonError))then
        begin
          var reason := 'error from JSONObjectWithData';
          raise new ProxyException withName('ProxyException') reason(reason) userInfo(nil) FromUrl(url);
        end;

        exit blockData;
      end;

      exit nil;

    end;
    {$ELSE}


    method WebRequestAsString(webMethod:String; url:String; jsonBody:Object;addAuthentication:Boolean := true):String;
    begin
      var client := new HttpClient;

      var requestMessage:HttpRequestMessage;

      if(not assigned(_requestBuilder))then
      begin
        requestMessage := new Moshine.Foundation.Web.HttpRequest(webMethod, url);
      end
      else
      begin
        requestMessage := _requestBuilder(url, webMethod,addAuthentication);
      end;

      if(assigned(jsonBody))then
      begin
        var someJson := JsonConvert.SerializeObject(jsonBody);
        var content := new StringContent(someJson, Encoding.UTF8, 'application/json');
        requestMessage.Content := content;
      end;

      var response := client.SendAsync(requestMessage).Result;

      if(response.IsSuccessStatusCode)then
      begin
        exit response.Content.ReadAsStringAsync.Result;
      end;

      var exception := new HttpStatusCodeException();
      exception.StatusCode := Integer(response.StatusCode);
      raise exception;

    end;

    method WebRequestAsObject(webMethod:String; url:String; jsonBody:Object;addAuthentication:Boolean := true):Object;
    begin
      exit JsonConvert.DeserializeObject<Dictionary<String,Object>>(WebRequestAsString(webMethod, url, jsonBody, addAuthentication));
    end;

    {$ENDIF}

  end;

end.