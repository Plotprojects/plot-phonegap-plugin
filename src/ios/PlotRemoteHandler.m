#import "PlotRemoteHandler.h"
#import "Plot.h"

static NSString * const NOTIFICATION_FILTER_URL_KEY = @"notification-filter-url";
static NSString * const GEOTRIGGER_HANDLER_URL_KEY = @"geotrigger-handler-url";

@implementation PlotRemoteHandler

-(void)filterNotifications:(PlotFilterNotifications*)filterNotifications {
    NSString* url = [self getUrlForKey:NOTIFICATION_FILTER_URL_KEY];
    if (url == nil) {
        [filterNotifications showNotifications:filterNotifications.uiNotifications];
        return;
    }
    
    NSMutableArray* userInfoDictionaries = [NSMutableArray array];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    for (UILocalNotification* n in filterNotifications.uiNotifications) {
        [userInfoDictionaries addObject:n.userInfo];
    }
#pragma clang diagnostic pop
    NSError* error = nil;
    NSData* notificationData = [self triggersToJson:userInfoDictionaries
                                          fieldName:@"notifications"
                                       messageField:@"message"
                                              error:&error];
    
    if (error != nil) {
        NSLog(@"Failed to prepare for request: %@", error);
        [filterNotifications showNotifications:@[]];
        return;
    }
    
    
    [self doHttpRequestForUrl:url requestBody:notificationData callback:^(BOOL success, NSData* data) {
        if (!success) {
            [filterNotifications showNotifications:nil];
            return;
        }
        
        NSError* errorInCallback = nil;
        
        NSArray* filteredNotifications = [self parseNotificationFilterResponse:data error:&errorInCallback];
        
        if (errorInCallback != nil) {
            NSLog(@"Failed to parse response: %@", filteredNotifications);
            [filterNotifications showNotifications:nil];
        } else {
            [self applyNotificationFilter:filterNotifications
                    selectedNotifications:filteredNotifications];
        }
    }];
    
}


-(void)applyNotificationFilter:(PlotFilterNotifications*)filterNotifications
selectedNotifications:(NSArray*)notifications {
    
    NSMutableArray* notificationsToSend = [NSMutableArray array];
    
    for (NSDictionary* n in notifications) {
        NSString* identifier = [n objectForKey:@"identifier"];
        NSString* message = [n objectForKey:@"message"];
        NSString* data = [n objectForKey:@"data"];
        
        BOOL found = NO;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        for (UILocalNotification* plotNotification in filterNotifications.uiNotifications) { //arrays should stay small
            NSString* plotIdentifier = [plotNotification.userInfo objectForKey:PlotNotificationIdentifier];
            if ([plotIdentifier isEqualToString:identifier]) {
                if (message != nil) {
                    plotNotification.alertBody = [message stringByReplacingOccurrencesOfString:@"%" withString:@"%%"];
                }
                if (data != nil) {
                    NSMutableDictionary* newUserInfo = [NSMutableDictionary dictionaryWithDictionary:plotNotification.userInfo];
                    [newUserInfo setObject:data forKey:PlotNotificationDataKey];
                    plotNotification.userInfo = newUserInfo;
                }
                
                found = YES;
                [notificationsToSend addObject:plotNotification];
                break;
            }
        }
        
        if (!found) {
            NSLog(@"Notification with ID '%@' not found", identifier);
        }
    }
#pragma clang diagnostic pop
    
    [filterNotifications showNotifications:notificationsToSend];
}

-(void)handleGeotriggers:(PlotHandleGeotriggers*)geotriggerHandler {
    [geotriggerHandler markGeotriggersHandled:geotriggerHandler.geotriggers];
    
    NSString* url = [self getUrlForKey:GEOTRIGGER_HANDLER_URL_KEY];
    if (url == nil) {
        return;
    }
    
    NSMutableArray* userInfoDictionaries = [NSMutableArray array];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    for (PlotGeotrigger* n in geotriggerHandler.geotriggers) {
        [userInfoDictionaries addObject:n.userInfo];
    }
#pragma clang diagnostic pop
    NSError* error = nil;
    NSData* notificationData = [self triggersToJson:userInfoDictionaries
                                          fieldName:@"geotriggers"
                                       messageField:@"name"
                                              error:&error];
    
    if (error != nil) {
        NSLog(@"Failed to prepare for geotrigger request: %@", error);
        return;
    }
    
    [self doHttpRequestForUrl:url requestBody:notificationData callback:^(BOOL success, NSData* data) {
        //do nothing
    }];
    
}

-(NSObject*)readKey:(NSString*)key fromDict:(NSDictionary*)dict {
    NSObject* value = [dict objectForKey:key];
    
    if (value == nil) {
        return [NSNull null];
    }
    return value;
}

-(NSData*)triggersToJson:(NSArray*)triggers
fieldName:(NSString*)fieldName
messageField:(NSString*)messageField
error:(NSError**)error {
    if (*error != nil) {
        return nil;
    }
    
    NSMutableArray* requestData = [NSMutableArray array];
    
    for (NSDictionary* userInfo in triggers) {
        NSObject* identifier = [self readKey:PlotNotificationIdentifier fromDict:userInfo];
        NSObject* message = [self readKey:PlotNotificationMessage fromDict:userInfo];
        NSObject* data = [self readKey:PlotNotificationDataKey fromDict:userInfo];
        NSObject* latitude = [self readKey:PlotNotificationGeofenceLatitude fromDict:userInfo];
        NSObject* longitude = [self readKey:PlotNotificationGeofenceLongitude fromDict:userInfo];
        NSObject* trigger = [self readKey:PlotNotificationTrigger fromDict:userInfo];
        NSObject* matchId = [self readKey:PlotNotificationMatchIdentifier fromDict:userInfo];
        NSObject* matchRange = [self readKey:PlotNotificationMatchRange fromDict:userInfo];
        NSObject* regionType = [self readKey:PlotNotificationRegionType fromDict:userInfo];
        
        NSDictionary* row = @{
                              @"identifier": identifier,
                              @"data": data,
                              messageField: message,
                              @"latitude": latitude,
                              @"longitude": longitude,
                              @"trigger": trigger,
                              @"matchIdentifier": matchId,
                              @"matchRange": matchRange,
                              @"regionType": regionType
                              };
        [requestData addObject:row];
    }
    
    
    NSDictionary* requestBody = @{
                                  fieldName: requestData
                                  };
    
    return [NSJSONSerialization dataWithJSONObject:requestBody
                                           options:0
                                             error:error];
}

-(NSArray*)parseNotificationFilterResponse:(NSData*)responseData
error:(NSError**)error {
    if (*error != nil) {
        return nil;
    }
    
    id response = [NSJSONSerialization JSONObjectWithData:responseData
                                                  options:0
                                                    error:error];
    if (*error != nil) {
        return nil;
    }
    if (![response isKindOfClass:[NSDictionary class]]) {
        *error = [NSError errorWithDomain:@"Plot"
                                     code:-1
                                 userInfo:@{NSLocalizedDescriptionKey: @"Server response not in the right format. Expected JsObject"}];
        return nil;
    }
    
    
    NSDictionary* responseDict = (NSDictionary*)response;
    
    NSArray* notifications = [responseDict objectForKey:@"notifications"];
    if (![notifications isKindOfClass:[NSArray class]]) {
        *error = [NSError errorWithDomain:@"Plot"
                                     code:-2
                                 userInfo:@{NSLocalizedDescriptionKey: @"Notification object missing"}];
        return nil;
    }
    
    return notifications;
}

-(void)doHttpRequestForUrl:(NSString*)url
requestBody:(NSData*)requestBody
callback:(void (^)(BOOL success, NSData* data)) callback {
    NSURLSessionConfiguration *ephemeralConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    ephemeralConfiguration.HTTPAdditionalHeaders = @{@"Accept": @"application/json", @"Content-Type": @"application/json"};
    
    NSURLSession *ephemeralSession = [NSURLSession sessionWithConfiguration:ephemeralConfiguration];
    
    NSURL* urlObj = [NSURL URLWithString:url];
    if (urlObj == nil) {
        NSLog(@"Illegal url: %@", url);
        callback(NO, nil);
        return;
    }
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:urlObj];
    request.HTTPBody = requestBody;
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 20;
    
    NSURLSessionDataTask* task = [ephemeralSession dataTaskWithRequest:request
                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                         if (error == nil) {
                                                             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                             NSInteger statusCode = [httpResponse statusCode];
                                                             if (statusCode >= 200 && statusCode < 300) {
                                                                 callback(YES, data);
                                                             } else {
                                                                 NSLog(@"Failed filter request: Unexpected status code: %ld", (long) statusCode);
                                                                 callback(NO, nil);
                                                             }
                                                         } else {
                                                             NSLog(@"Failed to perform filter request: %@", error);
                                                             callback(NO, nil);
                                                         }
                                                     }];
    [task resume];
}

-(void)saveUrl:(NSString*)url forKey:(NSString*)key {
    if (url == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:url forKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)getUrlForKey:(NSString*)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

-(void)setRemoteNotificationFilter:(NSString*)url {
    [self saveUrl:url forKey:NOTIFICATION_FILTER_URL_KEY];
}

-(void)setRemoteGeotriggerHandler:(NSString*)url {
    [self saveUrl:url forKey:GEOTRIGGER_HANDLER_URL_KEY];
}


-(BOOL)hasRemoteNotificationFilter {
    return [self getUrlForKey:NOTIFICATION_FILTER_URL_KEY] != nil;
}

-(BOOL)hasRemoteGeotriggerHandler {
    return [self getUrlForKey:GEOTRIGGER_HANDLER_URL_KEY] != nil;
}

@end
