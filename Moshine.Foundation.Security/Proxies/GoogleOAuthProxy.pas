namespace Moshine.Foundation.Security.Proxies;

uses
  Moshine.Foundation.Security.Models,
  Microsoft.Extensions.Logging,
  Newtonsoft.Json,
  System.Collections.Generic,
  System.Linq,
  System.Net.Http,
  System.Text,
  System.Threading.Tasks;

type

  GoogleOAuthProxy = public class
  private
    property Logger:ILogger;
  public
    constructor(loggerImpl:ILogger);
    begin
      Logger := loggerImpl;
    end;

    method GetUserInfoAsync(accessToken:String):Task<UserInformation>;
    begin

      var client := new HttpClient;
      var url := String.Format('https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token={0}',accessToken);
      var response := await client.GetAsync(url,HttpCompletionOption.ResponseContentRead);
      var stringResult := await response.Content.ReadAsStringAsync;

      var responseInformation := JsonConvert.DeserializeObject<AccessTokenInformation>(stringResult);


      if(not assigned(responseInformation.error))then
      begin
        Logger.LogTrace('userinfo success');

        var info := new UserInformation;

        info.Email := responseInformation.email;
        info.FamilyName := responseInformation.family_name;
        info.GivenName := responseInformation.given_name;
        info.Name := responseInformation.name;
        Logger.LogTrace('Returning info');
        exit info;
      end
      else
      begin
        Logger.LogTrace($'GetUserInfo Error Response {stringResult}');
      end;

      exit nil;
    end;

  end;

end.