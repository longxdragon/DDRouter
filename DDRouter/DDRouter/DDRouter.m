//
//  DDRouter.m
//  DDRouter
//
//  Created by longxdragon on 2016/12/23.
//  Copyright © 2016年 longxdragon. All rights reserved.
//

#import "DDRouter.h"
#import "NSObject+DDRouter.h"

@interface DDRouterHandler : NSObject
@property (nonatomic, copy) void (^callback)(NSDictionary *params);
@end

@implementation DDRouterHandler

@end


@implementation DDRouter {
    NSString *_mainHost;
    DDRouterMap *_mapper;
    NSMutableDictionary *_customMapper;
}

+ (DDRouter *)shareRouter {
    static dispatch_once_t onceToken;
    static DDRouter *router;
    dispatch_once(&onceToken, ^{
        router = [[DDRouter alloc] init];
    });
    return router;
}

- (void)configueMainHost:(NSString *)mainHost mapper:(DDRouterMap *)mapper {
    _mainHost = [mainHost copy];
    _mapper = mapper;
    _customMapper = [NSMutableDictionary new];
}

- (void)addEventName:(NSString *)name callback:(void (^)(NSDictionary *params))callback {
    if (name.length && callback) {
        DDRouterHandler *h = [DDRouterHandler new];
        h.callback = callback;
        _customMapper[name] = h;
    }
}

- (void)openUrl:(NSString *)urlString {
    [self openUrl:urlString toHandle:nil];
}

- (void)openUrl:(NSString *)urlString toHandle:(void(^)(UIViewController *viewController))handle {
    [self openUrl:urlString params:nil toHandle:handle];
}

- (void)openUrl:(NSString *)urlString params:(NSDictionary *)params toHandle:(void (^)(UIViewController *viewController))handle {
    NSString *scheme = @"";
    NSString *host = @"";
    NSString *lastPathComponent = @"";
    NSDictionary *queryDic = nil;
    if (!params) {
        NSURL *url = [NSURL URLWithString:urlString];
        scheme = url.scheme;
        host = url.host;
        lastPathComponent = url.lastPathComponent;
        NSString *query = url.query;
        queryDic = [self dictionaryFromQuery:query usingEncoding:NSUTF8StringEncoding];
    } else {
        NSURL *url = [NSURL URLWithString:urlString];
        scheme = url.scheme;
        host = url.host;
        lastPathComponent = url.lastPathComponent;
        queryDic = [params copy];
    }
    if ([scheme isEqualToString:_mainHost]) {
        // Custom event jump action
        if (host && _customMapper[host]) {
            DDRouterHandler *h = _customMapper[host];
            if (h.callback) {
                h.callback(queryDic);
            }
            return;
        }
        // Main module map
        NSDictionary *routerMapDic;
        if ([[_mapper class] respondsToSelector:@selector(mainRouterPathMapDictionary)]) {
            routerMapDic = [[_mapper class] mainRouterPathMapDictionary];
            if (!routerMapDic) return;
        }
        NSString *moduleName = [routerMapDic objectForKey:host];
        if (moduleName) {
            // Sub module map
            Class moduleRouterMap = NSClassFromString(moduleName);
            id<DDRouterProtocol> module = [[moduleRouterMap alloc] init];
            if ([[module class] respondsToSelector:@selector(subRouterPathMapDictionary)]) {
                NSDictionary *classMapDictionary = [[module class] performSelector:@selector(subRouterPathMapDictionary) withObject:nil];
                NSString *className = [classMapDictionary objectForKey:lastPathComponent];
                [self jumpToPath:className params:queryDic toHandle:handle];
            }
        } else {
            // None module just jump
            [self jumpToPath:host params:queryDic toHandle:handle];
        }
    }
}

#pragma mark - Private Method
- (void)jumpToPath:(NSString *)className params:(NSDictionary *)params toHandle:(void(^)(id params))handle {
    if ((!className || className.length == 0) && params == nil) return;
    Class t_class = NSClassFromString(className);
    id vc = [[t_class alloc] init];
    // Set properties
    [vc router_setPropertiesByDictionary:params];
    if (handle) {
        if (vc && [vc isKindOfClass:[UIViewController class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handle(vc);
            });
        }
    } else {
        if (vc && [vc isKindOfClass:[UIViewController class]]) {
            UIViewController *rootViewController = [self appRootViewController];
            if (!rootViewController) return;
            if ([rootViewController isKindOfClass:[UINavigationController class]]) {
                [(UINavigationController *)rootViewController pushViewController:vc animated:YES];
            } else {
                [rootViewController presentViewController:vc animated:YES completion:nil];
            }
        }
    }
}

- (NSDictionary*)dictionaryFromQuery:(NSString *)query usingEncoding:(NSStringEncoding)encoding {
    if (![query isKindOfClass:[NSString class]]) return nil;
    if (query.length == 0) return nil;
    NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
    NSScanner *scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString *pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray *kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString *key = [[kvPair objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSString *value = [[kvPair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:encoding];
            if (key && value) {
                [pairs setObject:value forKey:key];
            }
        }
    }
    return [NSDictionary dictionaryWithDictionary:pairs];
}

- (UIViewController *)appRootViewController {
    return [UIApplication sharedApplication].delegate.window.rootViewController;
}

@end
