namespace Moshine.Foundation.Security.Interfaces;

uses
  Moshine.Foundation.Security.Models;

type
  IUserRepository = public interface
    method FindAsync(email: String): Task<User>;
    method AddAsync(newUser: User): Task<User>;
  end;

end.