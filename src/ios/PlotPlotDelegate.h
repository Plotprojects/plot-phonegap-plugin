//
//  PlotPlotDelegate.h
//  myapp
//
//  Copyright © 2017 Floating Market B.V. All rights reserved.
//

#import "Plot.h"
#import <UserNotifications/UserNotifications.h>
#import "PlotCordovaPlugin.h"

@interface PlotPlotDelegate: NSObject<PlotDelegate> {
    
    id <PlotDelegate> delegate;
    
    NSMutableArray<UNNotificationRequest*>* notificationsToHandle;
    
    NSMutableArray<PlotFilterNotifications*>* notificationsToFilter;
            
}

@property id delegate;

-(void)plotHandleNotification:(UNNotificationRequest*)notification data:(NSString*)data;

-(void)plotFilterNotifications:(PlotFilterNotifications*)filterNotifications;

-(NSArray<UNNotificationRequest*>*)notificationsToHandle;

-(void)initNotificationsToHandle:(NSArray*)newNotifications;

-(NSArray<PlotFilterNotifications*>*)notificationsToFilter;

-(void)initNotificationsToFilter:(NSMutableArray<PlotFilterNotifications*>*)newFilterNotifications;

#ifndef PlotPlotDelegate_h
#define PlotPlotDelegate_h


#endif /* PlotPlotDelegate_h */

@end
