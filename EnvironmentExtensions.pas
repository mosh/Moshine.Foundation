namespace Moshine.Foundation.Shared;

type
  EnvironmentExtensions = public extension class(RemObjects.Elements.RTL.Environment)
  private
  protected
  public
    class method CommandLineArgs:array of String;
    begin
      {$IFDEF ECHOES}
      exit System.Environment.GetCommandLineArgs;
      {$ELSEIF TOFFEE OR DARWIN}
      exit Foundation.NSProcessInfo.processInfo.arguments;
      {$ELSE}
      raise NotImplementedException;
      {$ENDIF}

    end;
  end;

end.