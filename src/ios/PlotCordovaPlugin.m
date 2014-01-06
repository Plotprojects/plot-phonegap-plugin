//
//  PlotPlugin.m
//
//

#import "PlotCordovaPlugin.h"
#import "Plot.h"

@implementation PlotCordovaPlugin


static NSDictionary* launchOptions;


+(void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLocalNotification:)
                                                 name:CDVLocalNotification
                                               object:nil];
}

+(void)didFinishLaunching:(NSNotification*)notification {
    launchOptions = notification.userInfo;
    if (launchOptions == nil) {
        //launchOptions is nil when not start because of notification or url open
        launchOptions = [NSDictionary dictionary];
    }
}

+(void)didReceiveLocalNotification:(NSNotification*)notification {
    UILocalNotification* localNotification = [notification object];
    [Plot handleNotification:localNotification];
    
}

-(void)initPlot:(CDVInvokedUrlCommand*)command {
    if  (launchOptions != nil) {
        NSDictionary* args = [command.arguments objectAtIndex:0];
        
        NSString* publicKey = [args objectForKey:@"publicKey"];
        
        PlotConfiguration* config = [[PlotConfiguration alloc] initWithPublicKey:publicKey
                                                                        delegate:self];
        
        NSNumber* cooldownPeriod = [args objectForKey:@"cooldownPeriod"];
        
        if (cooldownPeriod != nil) {
            [config setCooldownPeriod:[cooldownPeriod intValue]];
        }
        
        NSNumber* enableOnFirstRun = [args objectForKey:@"enableOnFirstRun"];
        if (enableOnFirstRun != nil) {
            [config setEnableOnFirstRun:[enableOnFirstRun boolValue]];
        }
        
        [Plot initializeWithConfiguration:config launchOptions:launchOptions];
        launchOptions = nil;
    }
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)enable:(CDVInvokedUrlCommand*)command {
    [Plot enable];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)disable:(CDVInvokedUrlCommand*)command {
    [Plot disable];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)isEnabled:(CDVInvokedUrlCommand*)command {
    BOOL isEnabled = [Plot isEnabled];
    
    int result = (isEnabled) ? 1 : 0;
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)setCooldownPeriod:(CDVInvokedUrlCommand*)command {
    NSNumber* period = [command.arguments objectAtIndex:0];
    
    [Plot setCooldownPeriod:period.intValue];
    
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)getVersion:(CDVInvokedUrlCommand*)command {
    NSString* version = [Plot version];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:version];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)plotHandleNotification:(UILocalNotification*)notification data:(NSString*)data {
    NSDictionary* n = [NSDictionary dictionaryWithObjectsAndKeys:
                       [notification.userInfo objectForKey:@"identifier"], @"id",
                       notification.alertBody, @"message",
                       data, @"data",
                       nil];
    
    
    [self.commandDelegate evalJs:
     [NSString stringWithFormat:@"cordova.require(\"cordova/plugin/plot\")._runNotificationHandler(%@)", [n JSONString]]];
}

-(void)defaultNotificationHandler:(CDVInvokedUrlCommand*)command {
    //NSDictionary* notification = [command.arguments objectAtIndex:0];
    NSString* data = [command.arguments objectAtIndex:1];
    
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:data]];
}

-(void)plotFilterNotifications:(PlotFilterNotifications*)_filterNotifications {
    [filterNotificationsTimeoutTimer invalidate];
    filterNotificationsTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                                       target:self
                                                                     selector:@selector(plotFilterNotificationsTimeout)
                                                                     userInfo:nil
                                                                      repeats:NO];
    filterNotifications = _filterNotifications;
    NSMutableArray* notifications = [NSMutableArray arrayWithCapacity:filterNotifications.uiNotifications.count];
    
    for (UILocalNotification* uiNotification in filterNotifications.uiNotifications) {
        NSDictionary* notification = [NSDictionary dictionaryWithObjectsAndKeys:
                                      uiNotification.alertBody, @"message",
                                      [uiNotification.userInfo objectForKey:@"identifier"], @"id",
                                      [uiNotification.userInfo objectForKey:@"action"], @"data",
                                      nil];
        [notifications addObject: notification];
    }
    
    [self.commandDelegate evalJs:
     [NSString stringWithFormat:@"cordova.require(\"cordova/plugin/plot\")._runFilterCallback(%@)", [notifications JSONString]]
     ];
    
}

-(void)filterCallbackComplete:(CDVInvokedUrlCommand*)command {
    [filterNotificationsTimeoutTimer invalidate];
    filterNotificationsTimeoutTimer = nil;
    
    NSArray* notifications = [command.arguments objectAtIndex:0];
    
    NSMutableArray* notificationsToShow = [NSMutableArray array];
    
    for (NSDictionary* notification in notifications) {
        NSString* identifier = [notification objectForKey:@"id"];
        for (UILocalNotification* uiNotification in filterNotifications.uiNotifications) {
            if ([[uiNotification.userInfo objectForKey:@"identifier"] isEqualToString:identifier]) {
                uiNotification.alertBody = [notification objectForKey:@"message"];
                
                NSMutableDictionary* userInfo = [uiNotification.userInfo mutableCopy];
                [userInfo setObject:[notification objectForKey:@"data"] forKey:@"action"];
                uiNotification.userInfo = userInfo;
                
                [notificationsToShow addObject: uiNotification];
                break;
            }
        }
    }
    [filterNotifications showNotifications:notificationsToShow];
    filterNotifications = nil;
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)plotFilterNotificationsTimeout {
    filterNotifications = nil;
}


@end
