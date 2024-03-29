﻿namespace Moshine.Foundation.Shared;

uses
  RemObjects.Elements.System,
  RemObjects.Elements.RTL;

type
  EnvironmentExtensions = public extension class(RemObjects.Elements.RTL.Environment)
  private
  protected
  public
    class method CommandLineArgs:array of String;
    begin

      {$IFDEF ECHOES}
      exit System.Environment.GetCommandLineArgs;
      {$ELSEIF TOFFEE}
      exit Foundation.NSProcessInfo.processInfo.arguments.ToArray;
      {$ELSEIF DARWIN}
      exit Foundation.NSProcessInfo.processInfo.arguments.Cast<System.String>.ToArray;
      {$ELSE}
      raise new NotImplementedException;
      {$ENDIF}

    end;
  end;

end.