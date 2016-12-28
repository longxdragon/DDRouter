//
//  DDRouterProtocol.h
//  DDRouter
//
//  Created by longxdragon on 2016/12/23.
//  Copyright © 2016年 longxdragon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DDRouterProtocol <NSObject>

@optional
// 主模块的Map映射
+ (NSDictionary *)mainRouterPathMapDictionary;

// 模块内的Map映射
+ (NSDictionary *)subRouterPathMapDictionary;

@end
