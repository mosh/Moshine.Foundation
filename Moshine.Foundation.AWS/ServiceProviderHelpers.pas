namespace Moshine.Foundation.AWS;

uses
  Microsoft.Extensions.DependencyInjection;


type
  ServiceProviderHelpers = public static class
  public
    method Build:ServiceProvider;
    begin
      var collection := new ServiceCollection;

      var callingAssembly := typeOf(ServiceProviderHelpers).Assembly.GetCallingAssembly;

      var typeInCallingAssembly := callingAssembly.GetTypes.FirstOrDefault(t ->
      begin
        var attrs := t.GetCustomAttributes(typeOf(ServiceStartupAttribute),false);
        exit attrs.Any;
      end);

      if(assigned(typeInCallingAssembly))then
      begin
        var cons := typeInCallingAssembly.GetConstructor([]);

        var instance := cons.Invoke([]);

        var methodInfo := typeInCallingAssembly.GetMethod('Configure',[collection.GetType]);
        if(assigned(methodInfo))then
        begin
          methodInfo.Invoke(instance,[collection]);
        end
        else
        begin
          raise new NotImplementedException('Class with ServiceStartup Attribute does not contain Configure method.');
        end;
      end
      else
      begin
        raise new NotImplementedException('Cannot find class with ServiceStartup Attribute');
      end;

      exit collection.BuildServiceProvider;

    end;
  end;

end.