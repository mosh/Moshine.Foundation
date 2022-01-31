namespace Moshine.Foundation.Web;

uses
  {$IF TOFFEE OR DARWIN}
  Foundation,
  {$ELSEIF ECHOES}
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
      {$IFDEF TOFFEE OR DARWIN}
      exit WebRequestAsObject(webMethod,url,addAuthentication) as T;
      {$ELSEIF ECHOES}
      exit JsonConvert.DeserializeObject<T>(WebRequestAsString(webMethod, url, nil,addAuthentication));
      {$ENDIF}
    end;

    method WebRequestAsObject(webMethod:String; url:String;addAuthentication:Boolean := true):Object;
    begin
      exit WebRequestAsObject(webMethod, url, nil,addAuthentication);
    end;

    {$IFDEF ISLAND AND NOT DARWIN}
    method WebRequestAsObject(webMethod:String; url:String; obj:Object; addAuthentication:Boolean := true):Object;
    begin
      raise new NotImplementedException('WebRequestAsObject not implemented on this platform');
    end;
    {$ENDIF}


    {$IF TOFFEE OR DARWIN}
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

    {$IF TOFFEE OR DARWIN}

    method WebRequestAsString(request:HttpRequest):String;
    begin
      var stringResponse:String := nil;

      var errorReason:NSString := nil;
      var httpStatusCode := 200;

      var outerExecutionBlock: NSBlockOperation := NSBlockOperation.blockOperationWithBlock(method() begin

        var semaphore := dispatch_semaphore_create(0);

        var session := NSURLSession.sharedSession; // or create your own session with your own NSURLSessionConfiguration

        var task := session.dataTaskWithRequest(request) completionHandler(method (data:NSData; response:NSURLResponse; error:NSError)
          begin

            if(not assigned(error))then
            begin

              if(response is NSHTTPURLResponse)then
              begin
                var httpResponse := response as NSHTTPURLResponse;

                httpStatusCode := httpResponse.statusCode;

                if(httpStatusCode <> 200)then
                begin


                  errorReason := NSString.stringWithFormat('Url  %@ returned Invalid Status Code %d', request.Url, httpStatusCode);
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

        var url := request.Url;

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

    end;

    method WebRequestAsString(webMethod:String; url:String; jsonBody:NSData;addAuthentication:Boolean := true):String;
    begin

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


      exit WebRequestAsString(request);

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

    {$ELSEIF ECHOES}


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

      raise new HttpStatusCodeException(Integer(response.StatusCode));

    end;

    method WebRequestAsObject(webMethod:String; url:String; jsonBody:Object;addAuthentication:Boolean := true):Object;
    begin
      exit JsonConvert.DeserializeObject<Dictionary<String,Object>>(WebRequestAsString(webMethod, url, jsonBody, addAuthentication));
    end;

    {$ELSE}

    method WebRequestAsString(webMethod:String; url:String; jsonBody:Object;addAuthentication:Boolean := true):String;
    begin

      var request:HttpRequest;

      if(not assigned(_requestBuilder))then
      begin
        request := new HttpRequest(webMethod, url);
      end
      else
      begin
        request := _requestBuilder(url, webMethod,addAuthentication);
      end;

      if(assigned(jsonBody))then
      begin
        //request.JsonBody :=
        raise new NotImplementedException('JsonBody not implemented on this platform.');
      end;

      var response := Http.ExecuteRequestSynchronous(request);

      if(response.Success)then
      begin
        exit response.GetContentAsStringSynchronous;
      end;

      raise new HttpStatusCodeException(response.Code);

    end;

    {$ENDIF}

  end;

end.