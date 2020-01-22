namespace Moshine.Foundation.Web;

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

  {$IF TOFFEE}
  RequestBuilderDelegate = public block(url:String;webMethod:String;addAuthentication:Boolean):NSMutableURLRequest;
  {$ENDIF}


  WebProxy = public class


  private

    {$IF TOFFEE}
    method setJsonBody(jsonBody:NSData) OfRequest(request:NSMutableURLRequest);
    begin
      request.setValue('application/json; charset=utf-8') forHTTPHeaderField('Content-Type');
      request.setValue('application/json') forHTTPHeaderField('Accept');
      request.setValue( $'{jsonBody.length}' ) forHTTPHeaderField('Content-Length');
      request.setHTTPBody(jsonBody);
    end;
    {$ENDIF}

  protected

    {$IF TOFFEE}
    _requestBuilder:RequestBuilderDelegate;
    {$ENDIF}

    method WebRequestAsType<T>(webMethod:String; url:String;addAuthentication:Boolean := true):T;
    begin
      exit WebRequestAsObject(webMethod,url,addAuthentication) as T;
    end;

    method WebRequestAsObject(webMethod:String; url:String;addAuthentication:Boolean := true):Object;
    begin
      exit WebRequestAsObject(webMethod, url, nil,addAuthentication);
    end;

    {$IF TOFFEE}
    method WebRequestAsType<T>(webMethod:String; url:String; jsonBody:NSData;addAuthentication:Boolean := true):T;
    begin
      exit WebRequestAsType<T>(webMethod, url, jsonBody, addAuthentication);
    end;
    {$ENDIF}

    {$IF TOFFEE}

    method WebRequestAsString(webMethod:String; url:String; jsonBody:NSData;addAuthentication:Boolean := true):String;
    begin
      NSLog('WebRequest Method %@ Url %@',webMethod,url);

      var stringResponse:String := nil;

      var request:NSMutableURLRequest;

      if(assigned(_requestBuilder))then
      begin
        request := _requestBuilder(url,webMethod,addAuthentication);
      end
      else
      begin
        request := new NSMutableURLRequest() withURL( new NSURL() withString( url ));
        request.setHTTPMethod(webMethod);
      end;


      if(assigned(jsonBody))then
      begin
        setJsonBody(jsonBody) OfRequest(request);
      end;

      var taskError:NSError;
      var reason:NSString := nil;
      var statusCode:NSInteger := 0;
      var blockData:NSObject := nil;

      var outerExecutionBlock: NSBlockOperation := NSBlockOperation.blockOperationWithBlock(method() begin

        var semaphore := dispatch_semaphore_create(0);

        var session := NSURLSession.sharedSession; // or create your own session with your own NSURLSessionConfiguration

        var task := session. dataTaskWithRequest(request) completionHandler(method (data:NSData; response:NSURLResponse; error:NSError)begin

          if(not assigned(error))then
          begin
            NSLog('WebRequest Method %@ Url %@ returned Response',webMethod,url);

            if(response is NSHTTPURLResponse)then
            begin
              var httpResponse := response as NSHTTPURLResponse;

              statusCode := httpResponse.statusCode;

              NSLog('UrlResponse Method %@ Url %@ Response %ld',webMethod,url,statusCode);

              if(statusCode <> 200)then
              begin
                reason := NSString.stringWithFormat('Url  %@ returned Invalid Status Code %ld', url, statusCode);
              end;

            end;

            if(String.IsNullOrEmpty(reason))then
            begin
              stringResponse := new NSString withData(data) encoding(NSStringEncoding.NSUTF8StringEncoding);
            end;
          end
          else
          begin
            taskError := error;
          end;

          dispatch_semaphore_signal(semaphore);
        end);

        task.resume;

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

      end);

      var workerQueue := new NSOperationQueue();
      workerQueue.addOperations([outerExecutionBlock]) waitUntilFinished(true);

      if(not String.IsNullOrEmpty(reason))then
      begin
        if(statusCode = 0)then
        begin
          raise new ProxyException withName('ProxyException') reason(reason) userInfo(nil) FromUrl(url);
        end
        else
        begin
          if(statusCode = 401)then
          begin
            NSLog('%@','raising AuthenticationRequiredException from 401 statusCode');
            raise new AuthenticationRequiredException withName('AuthenticationRequired') reason('authentication required from 401 statusCode') userInfo(nil) FromUrl(url);
          end
          else
          begin
            raise new HttpStatusCodeException withName('ProxyException') reason(reason) userinfo(nil) StatusCode(statusCode) FromUrl(url);
          end;
        end;
      end;

      exit stringResponse;

    end;


    method WebRequestAsObject(webMethod:String; url:String; jsonBody:NSData;addAuthentication:Boolean := true):Object;
    begin


      var stringResponse := WebRequestAsString(webMethod, url, jsonBody, addAuthentication);

      if (not string.IsNullOrEmpty(stringResponse)) then
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

    method MethodToHttpMethod(webMethod:String):HttpMethod;
    begin
      exit case webMethod of
        'GET': HttpMethod.Get;
        'PUT': HttpMethod.Put;
        'POST': HttpMethod.Post;
        'DELETE': HttpMethod.Delete;
        else
          raise new ArgumentException($'Invalid method {webMethod}');
      end;
    end;

    method WebRequestAsString(webMethod:String; url:String; jsonBody:Object;addAuthentication:Boolean := true):String;
    begin
      var client := new HttpClient;

      var requestMessage := new HttpRequestMessage(MethodToHttpMethod(webMethod), url);

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