//
//  PlotPlugin.m
//  http://www.plotprojects.com/
//

#import "PlotCordovaPlugin.h"
#import "Plot.h"
#import <UIKit/UIKit.h>

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
        NSDictionary* args = (command.arguments.count > 0u) ? [command.arguments objectAtIndex:0] : nil;
        
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
        
        NSMutableDictionary* extendedLaunchOptions = [NSMutableDictionary dictionaryWithDictionary:launchOptions];
        
        [extendedLaunchOptions setObject:[NSNumber numberWithBool:YES] forKey:@"plot-use-file-config"];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if ([[args objectForKey:@"debug"] boolValue]) {
            [PlotDebug initializeWithConfiguration:config launchOptions:extendedLaunchOptions];
        } else {
            [PlotRelease initializeWithConfiguration:config launchOptions:extendedLaunchOptions];
        }
#pragma clang diagnostic pop
        
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

-(void)loadedNotifications:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSMutableArray* result = [NSMutableArray array];
        NSArray* notifications = [Plot loadedNotifications];
        
        for (UILocalNotification* uiNotification in notifications) {
            [result addObject:[self uiNotificationToDictionary:uiNotification]];
        }
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)loadedGeotriggers:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSMutableArray* result = [NSMutableArray array];
        NSArray* notifications = [Plot loadedGeotriggers];
        
        for (PlotGeotrigger* geotrigger in notifications) {
            [result addObject:[self geotriggerToDictionary:geotrigger]];
        }
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)getVersion:(CDVInvokedUrlCommand*)command {
    NSString* version = [Plot version];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:version];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)plotHandleNotification:(UILocalNotification*)notification data:(NSString*)data {
    NSDictionary* n = [self uiNotificationToDictionary:notification];
    
    [self.commandDelegate evalJs:
     [NSString stringWithFormat:@"cordova.require(\"cordova/plugin/plot\")._runNotificationHandler(%@)", [self toJson:n]]];
}

-(void)defaultNotificationHandler:(CDVInvokedUrlCommand*)command {
    //NSDictionary* notification = [command.arguments objectAtIndex:0];
    NSString* data = [command.arguments objectAtIndex:1];
    
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:data]];
}

-(NSDictionary*)uiNotificationToDictionary:(UILocalNotification*)uiNotification {
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   uiNotification.alertBody, @"message",
                                   [uiNotification.userInfo objectForKey:@"identifier"], @"id",
                                   [uiNotification.userInfo objectForKey:@"action"], @"data",
                                   [uiNotification.userInfo objectForKey:@"trigger"], @"trigger",
                                   [uiNotification.userInfo objectForKey:@"geofenceLatitude"], @"geofenceLatitude",
                                   [uiNotification.userInfo objectForKey:@"geofenceLongitude"], @"geofenceLongitude",
                                   [uiNotification.userInfo objectForKey:@"dwellingMinutes"], @"dwellingMinutes",
                                   [uiNotification.userInfo objectForKey:@"notificationHandlerType"], @"notificationHandlerType",
                                   [uiNotification.userInfo objectForKey:@"regionType"], @"regionType",
                                   [uiNotification.userInfo objectForKey:@"matchRange"], @"matchRange",
                                   nil];
    
    if ([uiNotification.userInfo objectForKey:@"matchIdentifier"]) {
        [result setObject:[uiNotification.userInfo objectForKey:@"matchIdentifier"] forKey:@"matchIdentifier"];
    }
    
    return result;
}

-(NSDictionary*)geotriggerToDictionary:(PlotGeotrigger*)geotrigger {
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [geotrigger.userInfo objectForKey:@"message"], @"name",
                                   [geotrigger.userInfo objectForKey:@"identifier"], @"id",
                                   [geotrigger.userInfo objectForKey:@"action"], @"data",
                                   [geotrigger.userInfo objectForKey:@"trigger"], @"trigger",
                                   [geotrigger.userInfo objectForKey:@"geofenceLatitude"], @"geofenceLatitude",
                                   [geotrigger.userInfo objectForKey:@"geofenceLongitude"], @"geofenceLongitude",
                                   [geotrigger.userInfo objectForKey:@"notificationHandlerType"], @"notificationHandlerType",
                                   [geotrigger.userInfo objectForKey:@"regionType"], @"regionType",
                                   [geotrigger.userInfo objectForKey:@"matchRange"], @"matchRange",
                                   nil];
    
    if ([geotrigger.userInfo objectForKey:@"matchIdentifier"]) {
        [result setObject:[geotrigger.userInfo objectForKey:@"matchIdentifier"] forKey:@"matchIdentifier"];
    }
    
    return result;
}

- (NSString*)toJson:(id)jsonObj
{
    NSError* error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (error != nil) {
        NSLog(@"NSDictionary JSONString error: %@", [error localizedDescription]);
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
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
        [notifications addObject:[self uiNotificationToDictionary:uiNotification]];
    }
    
    [self.commandDelegate evalJs:
     [NSString stringWithFormat:@"cordova.require(\"cordova/plugin/plot\")._runFilterCallback(%@)", [self toJson:notifications]]
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

-(void)setStringSegmentationProperty:(CDVInvokedUrlCommand*)command {
    NSString* property = [command.arguments objectAtIndex:0];
    NSString* value = [command.arguments objectAtIndex:1];
    
    [Plot setStringSegmentationProperty:value forKey:property];
        
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)setBooleanSegmentationProperty:(CDVInvokedUrlCommand*)command {
    NSString* property = [command.arguments objectAtIndex:0];
    NSNumber* value = [command.arguments objectAtIndex:1];
    
    [Plot setBooleanSegmentationProperty:value.boolValue forKey:property];
        
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)setIntegerSegmentationProperty:(CDVInvokedUrlCommand*)command {
    NSString* property = [command.arguments objectAtIndex:0];
    NSNumber* value = [command.arguments objectAtIndex:1];
    
    [Plot setIntegerSegmentationProperty:value.longLongValue forKey:property];
        
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)setDoubleSegmentationProperty:(CDVInvokedUrlCommand*)command {
    NSString* property = [command.arguments objectAtIndex:0];
    NSNumber* value = [command.arguments objectAtIndex:1];
    
    [Plot setDoubleSegmentationProperty:value.doubleValue forKey:property];
        
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)setDateSegmentationProperty:(CDVInvokedUrlCommand*)command {
    NSString* property = [command.arguments objectAtIndex:0];
    NSString* value = [NSString stringWithFormat:@"%@", [command.arguments objectAtIndex:1]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZZZ"];

    NSDate *date = [dateFormat dateFromString:value];
    [Plot setDateSegmentationProperty:date forKey:property];
        
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

//The data for the debug log on iOS is only collected when the DEBUG preprocessor macro is set.
-(void)mailDebugLog:(CDVInvokedUrlCommand*)command {
    [Plot mailDebugLog:self.viewController];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
