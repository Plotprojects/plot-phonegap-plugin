//
//  PlotCordovaPlugin.m
//  https://www.plotprojects.com/
//

#import "PlotCordovaPlugin.h"
#import "Plot.h"
#import <UIKit/UIKit.h>
#import "PlotPlotDelegate.h"

@implementation PlotCordovaPlugin


static NSDictionary* launchOptions;
static PlotPlotDelegate* plotDelegate;


+(void)load {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
}

+(void)didFinishLaunching:(NSNotification*)notification {
    launchOptions = notification.userInfo;
    if (launchOptions == nil) {
        //launchOptions is nil when not start because of notification or url open
        launchOptions = [NSDictionary dictionary];
    }
    
    plotDelegate = [[PlotPlotDelegate alloc] init];
    [Plot initializeWithLaunchOptions:launchOptions delegate:plotDelegate];
}

-(void)pluginInitialize {
    [super pluginInitialize];
    
    remoteHandler = [[PlotRemoteHandler alloc] init];
}

-(void)initPlot:(CDVInvokedUrlCommand*)command {
    if  (launchOptions != nil) {
        NSDictionary* args = (command.arguments.count > 0u) ? [command.arguments objectAtIndex:0] : nil;
        
        [plotDelegate setDelegate:self];
        
        NSArray<PlotFilterNotifications*>* notificationsToFilter = [plotDelegate notificationsToFilter];
        for(PlotFilterNotifications* n in notificationsToFilter) {
            [plotDelegate plotFilterNotifications:n];
        }
        
        NSArray<UNNotificationRequest*>* notificationsToHandle = [plotDelegate notificationsToHandle];
        for(UNNotificationRequest* n in notificationsToHandle){
            [plotDelegate plotHandleNotification:n data:Nil];
        }
        
        NSString* remoteNotificationFilter = [args objectForKey:@"remoteNotificationFilter"];
        [remoteHandler setRemoteNotificationFilter:remoteNotificationFilter];
        
        NSString* remoteGeotriggerHandler = [args objectForKey:@"remoteGeotriggerHandler"];
        [remoteHandler setRemoteGeotriggerHandler:remoteGeotriggerHandler];
        
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

-(void)loadedNotifications:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSMutableArray* result = [NSMutableArray array];
        NSArray* notifications = [Plot loadedNotifications];
        
        for (UNNotificationRequest* uiNotification in notifications) {
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

-(void)sentNotifications:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSMutableArray* result = [NSMutableArray array];
        NSArray* sentNotifications = [Plot sentNotifications];
        
        for (PlotSentNotification* sentNotification in sentNotifications) {
            [result addObject:[self sentNotificationToDictionary:sentNotification]];
        }
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)sentGeotriggers:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        NSMutableArray* result = [NSMutableArray array];
        NSArray* sentGeotriggers = [Plot sentGeotriggers];
        
        for (PlotSentGeotrigger* sentGeotrigger in sentGeotriggers) {
            [result addObject:[self sentGeotriggerToDictionary:sentGeotrigger]];
        }
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:result];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)clearSentNotifications:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        [Plot clearSentNotifications];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)clearSentGeotriggers:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        [Plot clearSentGeotriggers];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void)getVersion:(CDVInvokedUrlCommand*)command {
    NSString* version = [Plot version];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:version];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)plotHandleNotification:(UNNotificationRequest*)notification data:(NSString*)data {
    NSDictionary* n = [self uiNotificationToDictionary:notification];
    
    [self.commandDelegate evalJs:
     [NSString stringWithFormat:@"cordova.require(\"cordova/plugin/plot\")._runNotificationHandler(%@)", [self toJson:n]]];
}

-(void)defaultNotificationHandler:(CDVInvokedUrlCommand*)command {
    //NSDictionary* notification = [command.arguments objectAtIndex:0]
    NSString* data = [command.arguments objectAtIndex:1];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:data] options:@{} completionHandler:^(BOOL success){
        if(!success) {
            NSLog(@"Unable to open URL.");
        }
    }];
}

-(NSDictionary*)uiNotificationToDictionary:(UNNotificationRequest*)uiNotification {
    
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   uiNotification.content.body, @"message",
                                   [uiNotification.content.userInfo objectForKey:@"identifier"], @"id",
                                   [uiNotification.content.userInfo objectForKey:@"action"], @"data",
                                   [uiNotification.content.userInfo objectForKey:@"trigger"], @"trigger",
                                   [uiNotification.content.userInfo objectForKey:@"geofenceLatitude"], @"geofenceLatitude",
                                   [uiNotification.content.userInfo objectForKey:@"geofenceLongitude"], @"geofenceLongitude",
                                   [uiNotification.content.userInfo objectForKey:@"dwellingMinutes"], @"dwellingMinutes",
                                   [uiNotification.content.userInfo objectForKey:@"notificationHandlerType"], @"notificationHandlerType",
                                   [uiNotification.content.userInfo objectForKey:@"regionType"], @"regionType",
                                   [uiNotification.content.userInfo objectForKey:@"matchRange"], @"matchRange",
                                   nil];
    
    if ([uiNotification.content.userInfo objectForKey:@"matchIdentifier"]) {
        [result setObject:[uiNotification.content.userInfo objectForKey:@"matchIdentifier"] forKey:@"matchIdentifier"];
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
                                   [geotrigger.userInfo objectForKey:@"regionType"], @"regionType",
                                   [geotrigger.userInfo objectForKey:@"matchRange"], @"matchRange",
                                   nil];
    
    if ([geotrigger.userInfo objectForKey:@"matchIdentifier"]) {
        [result setObject:[geotrigger.userInfo objectForKey:@"matchIdentifier"] forKey:@"matchIdentifier"];
    }
    
    return result;
}

-(NSDictionary*)sentNotificationToDictionary:(PlotSentNotification*)sentNotification {
    NSDictionary* userInfo = sentNotification.userInfo;
    
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [userInfo objectForKey:@"message"], @"message",
                                   [userInfo objectForKey:@"identifier"], @"id",
                                   [userInfo objectForKey:@"matchIdentifier"], @"matchIdentifier",
                                   [userInfo objectForKey:@"action"], @"data",
                                   [userInfo objectForKey:@"trigger"], @"trigger",
                                   [userInfo objectForKey:@"geofenceLatitude"], @"geofenceLatitude",
                                   [userInfo objectForKey:@"geofenceLongitude"], @"geofenceLongitude",
                                   [userInfo objectForKey:@"dwellingMinutes"], @"dwellingMinutes",
                                   [userInfo objectForKey:@"notificationHandlerType"], @"notificationHandlerType",
                                   [userInfo objectForKey:@"regionType"], @"regionType",
                                   [userInfo objectForKey:@"matchRange"], @"matchRange",
                                   nil];
    
    [result setObject:@([sentNotification.dateSent timeIntervalSince1970]) forKey:@"dateSent"];
    if (sentNotification.dateOpened != nil) {
        [result setObject:@([sentNotification.dateOpened timeIntervalSince1970]) forKey:@"dateOpened"];
        [result setObject:@(YES) forKey:@"isOpened"];
    } else {
        [result setObject:@(-1) forKey:@"dateOpened"];
        [result setObject:@(NO) forKey:@"isOpened"];
    }
    
    return result;
}

-(NSDictionary*)sentGeotriggerToDictionary:(PlotSentGeotrigger*)sentGeotrigger {
    NSDictionary* userInfo = sentGeotrigger.userInfo;
    
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [userInfo objectForKey:@"message"], @"name",
                                   [userInfo objectForKey:@"identifier"], @"id",
                                   [userInfo objectForKey:@"matchIdentifier"], @"matchIdentifier",
                                   [userInfo objectForKey:@"action"], @"data",
                                   [userInfo objectForKey:@"trigger"], @"trigger",
                                   [userInfo objectForKey:@"geofenceLatitude"], @"geofenceLatitude",
                                   [userInfo objectForKey:@"geofenceLongitude"], @"geofenceLongitude",
                                   [userInfo objectForKey:@"dwellingMinutes"], @"dwellingMinutes",
                                   [userInfo objectForKey:@"regionType"], @"regionType",
                                   [userInfo objectForKey:@"matchRange"], @"matchRange",
                                   nil];
    
    [result setObject:@([sentGeotrigger.dateSent timeIntervalSince1970]) forKey:@"dateSent"];
    if (sentGeotrigger.dateHandled != nil) {
        [result setObject:@([sentGeotrigger.dateHandled timeIntervalSince1970]) forKey:@"dateHandled"];
        [result setObject:@(YES) forKey:@"isHandled"];
    } else {
        [result setObject:@(-1) forKey:@"dateHandled"];
        [result setObject:@(NO) forKey:@"isHandled"];
    }
    
    return result;
}

- (NSString*)toJson:(id)jsonObj {
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
    if ([remoteHandler hasRemoteNotificationFilter]) {
        [remoteHandler filterNotifications:_filterNotifications];
    } else {
        [filterNotificationsTimeoutTimer invalidate];
        filterNotificationsTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                                           target:self
                                                                         selector:@selector(plotFilterNotificationsTimeout)
                                                                         userInfo:nil
                                                                          repeats:NO];
        filterNotifications = _filterNotifications;
        NSMutableArray* notifications = [NSMutableArray arrayWithCapacity:filterNotifications.uiNotifications.count];
        
        for (UNNotificationRequest* uiNotification in filterNotifications.uiNotifications) {
            [notifications addObject:[self uiNotificationToDictionary:uiNotification]];
        }
        
        [self.commandDelegate evalJs:
         [NSString stringWithFormat:@"cordova.require(\"cordova/plugin/plot\")._runFilterCallback(%@)", [self toJson:notifications]]
         ];
    }
}

-(void)filterCallbackComplete:(CDVInvokedUrlCommand*)command {
    [filterNotificationsTimeoutTimer invalidate];
    filterNotificationsTimeoutTimer = nil;
    
    NSArray* notifications = [command.arguments objectAtIndex:0];
    
    NSMutableArray* notificationsToShow = [NSMutableArray array];
    
    for (NSDictionary* notification in notifications) {
        NSString* identifier = [notification objectForKey:@"id"];
        for (UNNotificationRequest* uiNotification in filterNotifications.uiNotifications) {
            if ([[uiNotification.content.userInfo objectForKey:@"identifier"] isEqualToString:identifier]) {
                NSString* newText = [notification objectForKey:@"message"];
                UNMutableNotificationContent* newContent =  [[UNMutableNotificationContent alloc] init];
                newContent.body = newText;
                
                NSMutableDictionary* userInfo = [uiNotification.content.userInfo mutableCopy];
                [userInfo setObject:[notification objectForKey:@"data"] forKey:@"action"];
                newContent.userInfo = userInfo;
                
                UNNotificationRequest* newNotification =  [UNNotificationRequest requestWithIdentifier:uiNotification.identifier content:newContent trigger:uiNotification.trigger];
                
                [notificationsToShow addObject: newNotification];
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

-(void)plotHandleGeotriggers:(PlotHandleGeotriggers*)geotriggerHandler {
    [remoteHandler handleGeotriggers:geotriggerHandler];
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
