namespace Moshine.Foundation.Web;

uses
  {$IF TOFFEE}
  Foundation,
  {$ENDIF}
  Moshine.Foundation,
  RemObjects.Elements.RTL;

type

  {$IF TOFFEE}
  RequestBuilderDelegate = public block(url:String;webMethod:String;addAuthentication:Boolean):NSMutableURLRequest;
  {$ENDIF}


  WebProxy = public class

  protected

    {$IF TOFFEE}
    _requestBuilder:RequestBuilderDelegate;
    {$ENDIF}

    method WebRequest<T>(webMethod:String; url:String;addAuthentication:Boolean := true):T;
    begin
      exit WebRequest(webMethod,url,addAuthentication) as T;
    end;

    method WebRequest(webMethod:String; url:String;addAuthentication:Boolean := true):Object;
    begin
      exit WebRequest(webMethod, url, nil,addAuthentication);
    end;

    {$IF TOFFEE}
    method WebRequest<T>(webMethod:String; url:String; jsonBody:NSData;addAuthentication:Boolean := true):T;
    begin
      exit WebRequest(webMethod, url, jsonBody, addAuthentication) as T;
    end;
    {$ENDIF}


    {$IF TOFFEE}
    method WebRequest(webMethod:String; url:String; jsonBody:NSData;addAuthentication:Boolean := true):Object;
    begin

      NSLog('WebRequest Method %@ Url %@',webMethod,url);

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

        var dataLength := jsonBody.length();
        var length := NSString.stringWithFormat('%ld', dataLength);

        request.setValue('application/json; charset=utf-8') forHTTPHeaderField('Content-Type');
        request.setValue('application/json') forHTTPHeaderField('Accept');
        request.setValue( length ) forHTTPHeaderField('Content-Length');

        request.setHTTPBody(jsonBody);

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

              var jsonError:NSError;

              blockData := NSJSONSerialization.JSONObjectWithData(data) options(NSJSONReadingOptions.NSJSONReadingMutableContainers ) error( var jsonError );

              if(assigned(jsonError))then
              begin
                blockData := nil;
                taskError := jsonError;
                reason := 'error from JSONObjectWithData';
              end;
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

      if(assigned(taskError))then
      begin
        NSLog('dataTashRequest returned error');

        if(taskError.code = NSURLErrorUserCancelledAuthentication)then
        begin
          NSLog('%@','raising AuthenticationRequiredException');
          raise new AuthenticationRequiredException withName('AuthenticationRequired') reason('authentication required') userInfo(nil) FromUrl(url);
        end;
        NSLog('%@','raising ProxyException');
        raise new ProxyException withName('ProxyException') reason('error from request') userInfo(nil) FromUrl(url);
      end;

      exit blockData;


    end;
    {$ELSE}
    method WebRequest(webMethod:String; url:String; jsonBody:Object;addAuthentication:Boolean := true):Object;
    begin

    end;

    {$ENDIF}

  end;

end.