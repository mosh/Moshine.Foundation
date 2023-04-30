namespace Moshine.Foundation.AWS;

type
  IAWSSecrets = public interface
    method GetSecretAsync(name:String):Task<IDictionary<String,Object>>;
  end;

end.