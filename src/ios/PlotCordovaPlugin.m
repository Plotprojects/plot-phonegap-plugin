//
//  PlotPlugin.m
//
//

#import "PlotCordovaPlugin.h"
#import "Plot.h"

@implementation PlotCordovaPlugin


static NSDictionary* launchOptions;


+(void)load {
    NSLog(@"Plot Loaded");
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
        
        NSNumber* enableBackgroundModeWarning = [args objectForKey:@"enableBackgroundModeWarning"];
        if (enableBackgroundModeWarning != nil) {
            [config setEnableBackgroundModeWarning:[enableBackgroundModeWarning boolValue]];
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

-(void)setEnableBackgroundModeWarning:(CDVInvokedUrlCommand*)command {
    NSNumber* backgroundWarningEnabled = [command.arguments objectAtIndex:0];
    [Plot setEnableBackgroundModeWarning:(backgroundWarningEnabled.intValue != 0) ? YES : NO];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)getVersion:(CDVInvokedUrlCommand*)command {
    NSString* version = [Plot version];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:version];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


@end
