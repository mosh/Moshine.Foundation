namespace Moshine.Foundation;

interface

uses
  Foundation, SystemConfiguration;

type


//struct sockaddr_in {
//  __uint8_t  sin_len;
//  sa_family_t  sin_family;
//  in_port_t  sin_port;
//  struct  in_addr sin_addr;
//  char    sin_zero[8];
//};
//typedef unsigned char    __uint8_t;
//typedef __uint8_t    sa_family_t;
//typedef  __uint16_t    in_port_t;
//typedef  unsigned short    __uint16_t;
//struct in_addr {
//  in_addr_t s_addr;
//};
//typedef  __uint32_t  in_addr_t;  /* base type for internet address */
//typedef unsigned int    __uint32_t;


  __uint8_t = UInt8;
  sa_family_t = __uint8_t;
  __uint16_t = UInt16;
  in_port_t = __uint16_t;
  __uint32_t = UInt32;
  in_addr_t = __uint32_t;

  in_addr = public record
  public
    s_addr:in_addr_t;
  end;

  sockaddr_in = public record
  public
    sin_len:__uint8_t;
    sin_family:sa_family_t;
    sin_port:in_port_t;
    sin_addr:in_addr;
    sin_zero:array of Char := new Char[8];
  end;


  NetworkStatus = public enum (NotReachable, ReachableViaWiFi, ReachableViaWWAN);

  Reachability = public class
  private
    const kReachabilityChangedNotification:String = 'kNetworkReachabilityChangedNotification';
    const kSCNetworkReachabilityFlagsTransientConnection:Int64 = 1 shl 0;
    const kSCNetworkReachabilityFlagsReachable:Int64 = 1 shl 1;
    const kSCNetworkReachabilityFlagsConnectionRequired:Int64 = 1 shl 2;
    const kSCNetworkReachabilityFlagsConnectionOnTraffic:Int64 = 1 shl 3;
    const kSCNetworkReachabilityFlagsInterventionRequired:Int64 = 1 shl 4;
    const kSCNetworkReachabilityFlagsConnectionOnDemand:Int64 = 1 shl 5;
    const kSCNetworkReachabilityFlagsIsLocalAddress:Int64 = 1 shl 16;
    const kSCNetworkReachabilityFlagsIsDirect:Int64 = 1 shl 17;
    {$IF TARGET_OS_IPHONE}
    const kSCNetworkReachabilityFlagsIsWWAN:Int64 = 1 shl 18;
    {$ENDIF}
    const kSCNetworkReachabilityFlagsConnectionAutomatic:Int32 = kSCNetworkReachabilityFlagsConnectionOnTraffic;


  private
    localWiFiRef:Boolean;
    reachabilityRef:SCNetworkReachabilityRef;

    method localWiFiStatusForFlags(&flags:SCNetworkReachabilityFlags):NetworkStatus;
    method networkStatusForFlags(&flags:SCNetworkReachabilityFlags):NetworkStatus;


  public

    method startNotifier:Boolean;
    method stopNotifier;
    method connectionRequired:Boolean;
    method currentReachabilityStatus:NetworkStatus;

    class method reachabilityWithHostName(hostName:NSString):Reachability;
    class method reachabilityWithAddress(hostAddress:^sockaddr_in):Reachability;
    class method reachabilityForInternetConnection:Reachability;
    class method reachabilityForLocalWiFi:Reachability;

    class method ReachabilityCallback (target:SCNetworkReachabilityRef; flags:SCNetworkReachabilityFlags; info: ^Object );


  end;


implementation

method Reachability.localWiFiStatusForFlags(&flags:SCNetworkReachabilityFlags):NetworkStatus;
begin

  var retVal := NetworkStatus.NotReachable;

  if( ((&flags and kSCNetworkReachabilityFlagsReachable) = kSCNetworkReachabilityFlagsReachable) and ((&flags and kSCNetworkReachabilityFlagsIsDirect) = kSCNetworkReachabilityFlagsIsDirect))then
  begin
    retVal := NetworkStatus.ReachableViaWiFi;
  end;
  exit retVal;

end;

method Reachability.networkStatusForFlags(&flags:SCNetworkReachabilityFlags):NetworkStatus;
begin

  if ((&flags and kSCNetworkReachabilityFlagsReachable) = 0)then
  begin
    // if target host is not reachable
    exit NetworkStatus.NotReachable;
  end;


  var retVal := NetworkStatus.NotReachable;

  if ((flags and kSCNetworkReachabilityFlagsConnectionRequired) = 0)then
  begin
    // if target host is reachable and no connection is required
    //  then we'll assume (for now) that your on Wi-Fi
    retVal := NetworkStatus.ReachableViaWiFi;
  end;

  if (
  ((&flags and kSCNetworkReachabilityFlagsConnectionOnDemand) <> 0) or
  ((&flags and kSCNetworkReachabilityFlagsConnectionOnTraffic) <> 0)
  )then
  begin
    // ... and the connection is on-demand (or on-traffic) if the
    //     calling application is using the CFSocketStream or higher APIs

    if ((flags and kSCNetworkReachabilityFlagsInterventionRequired) = 0)then
    begin
      // ... and no [user] intervention is needed
      retVal := NetworkStatus.ReachableViaWiFi;
    end;
  end;

  if ((&flags and kSCNetworkReachabilityFlagsIsWWAN) = kSCNetworkReachabilityFlagsIsWWAN)then
  begin
    // ... but WWAN connections are OK if the calling application
    //     is using the CFNetwork (CFSocketStream?) APIs.
    retVal := NetworkStatus.ReachableViaWWAN;
  end;
  exit retVal;

end;


class method Reachability.ReachabilityCallback (target:SCNetworkReachabilityRef; flags:SCNetworkReachabilityFlags; info: ^Object );
begin
  using autoreleasepool do
  begin
    var noteObject := bridge<Reachability>(info);
    // Post a notification to notify the client that the network reachability changed.
    NSNotificationCenter.defaultCenter.postNotificationName(kReachabilityChangedNotification) object(noteObject);
  end;
end;


method Reachability.connectionRequired: Boolean;
begin
  var flags:SCNetworkReachabilityFlags;

  if (SCNetworkReachabilityGetFlags(reachabilityRef, @flags)) then
  begin
    exit (&flags and SCNetworkReachabilityFlags.kSCNetworkReachabilityFlagsConnectionRequired) = SCNetworkReachabilityFlags.kSCNetworkReachabilityFlagsConnectionRequired;
  end;
  exit false;

end;



method Reachability.currentReachabilityStatus: NetworkStatus;
begin
  var retVal := NetworkStatus.NotReachable;
  var &flags:SCNetworkReachabilityFlags;

  if (SCNetworkReachabilityGetFlags(reachabilityRef, @flags))then
  begin
    if(localWiFiRef)then
    begin
      retVal := self.localWiFiStatusForFlags(&flags);
    end
    else
    begin
      retVal := self.networkStatusForFlags(&flags);
    end;
  end;
  exit retVal;
end;

class method Reachability.reachabilityForInternetConnection: Reachability;
begin
  var zeroAddress:sockaddr_in;
  bzero(@zeroAddress, sizeOf(zeroAddress));
  zeroAddress.sin_len := sizeOf(zeroAddress);
  zeroAddress.sin_family := AF_INET;
  exit reachabilityWithAddress(@zeroAddress);
end;

class method Reachability.reachabilityForLocalWiFi: Reachability;
begin
  var localWifiAddress:sockaddr_in;
  bzero(@localWifiAddress, sizeOf(localWifiAddress));
  localWifiAddress.sin_len := sizeOf(localWifiAddress);
  localWifiAddress.sin_family := AF_INET;
  localWifiAddress.sin_addr.s_addr := htonl(IN_LINKLOCALNETNUM);
  var retVal : Reachability := reachabilityWithAddress(@localWifiAddress);
  if(assigned(retVal))then
  begin
    retVal.localWiFiRef := true;
  end;
  exit retVal;


end;

class method Reachability.reachabilityWithAddress(hostAddress: ^sockaddr_in): Reachability;
begin

  var reachability:SCNetworkReachabilityRef  := SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, ^__struct_sockaddr(hostAddress));
  var retVal : Reachability := nil;
  if(assigned(reachability))then
  begin
    retVal := new Reachability;
    if(assigned(retVal))then
    begin
      retVal.reachabilityRef := reachability;
      retVal.localWiFiRef := false;
    end;
  end;
  exit retVal;
end;

class method Reachability.reachabilityWithHostName(hostName: NSString): Reachability;
begin
  var retVal:Reachability := nil;
  var reachability:SCNetworkReachabilityRef := SCNetworkReachabilityCreateWithName(nil, hostName.UTF8String);
  if ( assigned(reachability)) then
  begin
    retVal := new Reachability;
    if(assigned(retVal))then
    begin
      retVal.reachabilityRef := reachability;
      retVal.localWiFiRef := false;
    end;
  end;
  exit retVal;
end;

method Reachability.startNotifier: Boolean;
begin
  var callback:SCNetworkReachabilityCallBack;
  //callback := @ReachabilityCallback
  callback := method begin
  end;

  var retVal:Boolean := false;
  var context:SCDynamicStoreContext;

  context.version := 0;
  context.info := bridge<^Void>(self);
  context.retain:= nil;
  context.release := nil;
  context.copyDescription := nil;


  if(SCNetworkReachabilitySetCallback(reachabilityRef, callback, @context)) then
  begin
    if(SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetMain(), kCFRunLoopDefaultMode)) then // DFH CFRunLoopGetCurrent()
      begin
        retVal := true;
      end;
  end;
  exit retVal;
end;

method Reachability.stopNotifier;
begin
  if(assigned(reachabilityRef))then
  begin
    SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetMain(), kCFRunLoopDefaultMode);  // CFRunLoopGetCurrent()
  end;

end;


end.