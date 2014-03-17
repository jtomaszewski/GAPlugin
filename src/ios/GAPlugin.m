#import "GAPlugin.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "AppDelegate.h"

@implementation GAPlugin
- (void) initGA:(CDVInvokedUrlCommand*)command
{
    NSString    *callbackId = command.callbackId;
    NSString    *accountID = [command.arguments objectAtIndex:0];
    NSInteger   dispatchPeriod = [[command.arguments objectAtIndex:1] intValue];

    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = dispatchPeriod;
    // Optional: set debug to YES for extra debugging information.
    //[GAI sharedInstance].debug = YES;
    // Create tracker instance.
    [[GAI sharedInstance] trackerWithTrackingId:accountID];
    // Set the appVersion equal to the CFBundleVersion
//    [GAI sharedInstance].defaultTracker.appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    inited = YES;

    [self successWithMessage:[NSString stringWithFormat:@"initGA: accountID = %@; Interval = %d seconds",accountID, dispatchPeriod] toID:callbackId];
}

-(void) exitGA:(CDVInvokedUrlCommand*)command
{
    NSString *callbackId = command.callbackId;

    if (inited)
        [[[GAI sharedInstance] defaultTracker] set:kGAISessionControl value:@"end"];

    [self successWithMessage:@"exitGA" toID:callbackId];
}

- (void) trackEvent:(CDVInvokedUrlCommand*)command
{
    NSString        *callbackId = command.callbackId;
    NSString        *category = [command.arguments objectAtIndex:0];
    NSString        *eventAction = [command.arguments objectAtIndex:1];
    NSString        *eventLabel = [command.arguments objectAtIndex:2];
    NSInteger       eventValue = [[command.arguments objectAtIndex:3] intValue];
    NSError         *error = nil;

    if (inited)
    {
        id<GAITracker> tracker=[[GAI sharedInstance] defaultTracker];
        @try {
            NSDictionary *sendParameters = [[GAIDictionaryBuilder createEventWithCategory:category action:eventAction label:eventLabel value:[NSNumber numberWithInt:eventValue]] build];
            [tracker send:sendParameters];
            [self successWithMessage:[NSString stringWithFormat:@"trackEvent: category = %@; action = %@; label = %@; value = %d", category, eventAction, eventLabel, eventValue] toID:callbackId];
        }
        @catch (NSException *exception) {
            [self failWithMessage:@"trackEvent failed" toID:callbackId withError:error];
        }
    }
    else
        [self failWithMessage:@"trackEvent failed - not initialized" toID:callbackId withError:nil];
}

- (void) trackPage:(CDVInvokedUrlCommand*)command
{
    NSString            *callbackId = command.callbackId;
    NSString            *pageURL = [command.arguments objectAtIndex:0];

    if (inited)
    {
        NSError *error = nil;
        id<GAITracker> tracker=[[GAI sharedInstance] defaultTracker];
        @try {
            NSDictionary *sendParameters = [[[GAIDictionaryBuilder createAppView] set:pageURL forKey:kGAIScreenName] build];
            [tracker send:sendParameters];
            [self successWithMessage:[NSString stringWithFormat:@"trackPage: url = %@", pageURL] toID:callbackId];
        }
        @catch (NSException *exception) {
            [self failWithMessage:@"trackPage failed" toID:callbackId withError:error];
        }
    }
    else
        [self failWithMessage:@"trackPage failed - not initialized" toID:callbackId withError:nil];
}

- (void) setVariable:(CDVInvokedUrlCommand*)command
{
    NSString            *callbackId = command.callbackId;
    NSInteger           index = [[command.arguments objectAtIndex:0] intValue];
    NSString            *value = [command.arguments objectAtIndex:1];

    if (inited)
    {
        NSError *error = nil;
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        @try {
            [tracker set:[GAIFields customMetricForIndex:index] value:value];
            [self successWithMessage:[NSString stringWithFormat:@"setVariable: index = %d, value = %@;", index, value] toID:callbackId];
        }
        @catch (NSException *exception) {
            [self failWithMessage:@"setVariable failed" toID:callbackId withError:error];
        }
    }
    else
        [self failWithMessage:@"setVariable failed - not initialized" toID:callbackId withError:nil];
}

- (void) trackSocial:(CDVInvokedUrlCommand*) command
{
    NSString *callbackId = command.callbackId;
    NSString *network=[command.arguments objectAtIndex:0];
    NSString *action=[command.arguments objectAtIndex:1];
    NSString *targetUrl=[command.arguments objectAtIndex:2];


    if(inited)
    {
        NSError *error= nil;
        id tracker = [[GAI sharedInstance] defaultTracker];
        @try {
            [tracker send:[[GAIDictionaryBuilder createSocialWithNetwork:network action:action target:targetUrl] build]];
            [self successWithMessage: [NSString stringWithFormat:@"trackSocial: network = %@, action = %@, target=%@; ", network, action, targetUrl] toID:callbackId ];
        }
        @catch (NSException *exception) {
            [self failWithMessage:@"trackSocial failed" toID:callbackId withError:error];
        }
    }
    else
        [self failWithMessage: @" trackSocial failed - not initialized" toID:callbackId withError:nil];
}

- (void) trackEcommerceTransaction:(CDVInvokedUrlCommand*) command{
    
    
    NSString *callbackId = command.callbackId;
    
    NSString *transactionId;
    NSString *affiliation;
    NSNumber *revenue;
    NSNumber *tax;
    NSNumber *shipping;
    NSString *currencyCode;
    
    if(inited)
    {
        
        NSError *error=nil;
        id tracker=[[GAI sharedInstance] defaultTracker];
        @try {
            [tracker send:[[GAIDictionaryBuilder createTransactionWithId:(NSString *)transactionId affiliation:(NSString *)affiliation revenue:(NSNumber *)revenue tax:(NSNumber *)tax shipping:(NSNumber *)shipping currencyCode:(NSString *)currencyCode] build]];
            [self successWithMessage: [NSString stringWithFormat:@"trackEcommerceTransaction: transactionId=%@, affiliation=%@, revenue=%@, tax=%@, shipping=%@, currencyCode=%@", transactionId, affiliation, revenue, tax, shipping, currencyCode] toID:callbackId];
        }
        @catch (NSException *exception) {
            [self failWithMessage:@"trackEcommerceTransaction failed" toID:callbackId withError:error];
        }
    }
    else
        [self failWithMessage: @" trackEcommerceTransaction failed - not initialized" toID:callbackId withError:nil];
}

- (void) trackEcommerceItem:(CDVInvokedUrlCommand*) command{
    NSString *callbackId = command.callbackId;
    NSString *transactionId;
    NSString *name;
    NSString *sku;
    NSString *category;
    NSNumber *price;
    NSNumber *quantity;
    NSString *currencyCode;

    if(inited)
    {              

        NSError *error=nil;
        id tracker=[[GAI sharedInstance] defaultTracker];
        @try {
            [tracker send:[[GAIDictionaryBuilder createItemWithTransactionId:transactionId name:name sku:sku category:category price:price quantity:quantity currencyCode:currencyCode] build]];
            [self successWithMessage: [NSString stringWithFormat:@"trackEcommerceItem: transactionId=%@, name=%@, sku=%@, category=%@, price=%@, quantity=%@, currencyCode=%@", transactionId, name, sku, category, price, quantity, currencyCode] toID:callbackId];
        }
        @catch (NSException *exception) {
            [self failWithMessage:@"trackEcommerceItem failed" toID:callbackId withError:error];
        }
    }
    else
        [self failWithMessage: @" trackEcommerceItem failed - not initialized" toID:callbackId withError:nil];
}


-(void)successWithMessage:(NSString *)message toID:(NSString *)callbackID
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];

    [self writeJavascript:[commandResult toSuccessCallbackString:callbackID]];
}

-(void)failWithMessage:(NSString *)message toID:(NSString *)callbackID withError:(NSError *)error
{
    NSString        *errorMessage = (error) ? [NSString stringWithFormat:@"%@ - %@", message, [error localizedDescription]] : message;
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];

    [self writeJavascript:[commandResult toErrorCallbackString:callbackID]];
}

-(void)dealloc
{
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker close];
//    [super dealloc]; - No longer needed with arc
}

@end
