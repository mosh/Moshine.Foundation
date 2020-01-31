namespace Moshine.Foundation;

{$IF TOFFEE}

uses
  Foundation;

type
  ApplicationHelpers = public class
  public

    class method appVersion:String;
    begin
      var versionString := NSBundle.mainBundle.infoDictionary.objectForKey('CFBundleShortVersionString');
      var buildString := NSBundle.mainBundle.infoDictionary.objectForKey('CFBundleVersion');

      exit NSString.stringWithFormat('Version %@ Build %@',versionString,buildString);
    end;

  end;
{$ENDIF}
end.