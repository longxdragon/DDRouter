//
//  DDRouter.h
//  DDRouter
//
//  Created by longxdragon on 2016/12/23.
//  Copyright © 2016年 longxdragon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DDRouterMap.h"

@interface DDRouter : NSObject

+ (DDRouter *)shareRouter;

- (void)configueMainHost:(NSString *)mainHost mapper:(DDRouterMap *)mapper;

- (void)addEventName:(NSString *)name callback:(void (^)(NSDictionary *params))callback;

- (void)openUrl:(NSString *)urlString;

- (void)openUrl:(NSString *)urlString toHandle:(void(^)(UIViewController *viewController))handle;

- (void)openUrl:(NSString *)urlString params:(NSDictionary *)params toHandle:(void (^)(UIViewController *viewController))handle;

@end
