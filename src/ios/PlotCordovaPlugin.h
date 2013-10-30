//
//  PlotPlugin.h
//
//

#import <Foundation/Foundation.h>
#import "Plot.h"

#import <Cordova/CDV.h>

@interface PlotCordovaPlugin : CDVPlugin<PlotDelegate> {
    PlotFilterNotifications* filterNotifications;
    NSTimer* filterNotificationsTimeoutTimer;
}




@end
