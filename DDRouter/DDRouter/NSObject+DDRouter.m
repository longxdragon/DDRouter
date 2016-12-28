//
//  NSObject+DDRouter.m
//  DDRouter
//
//  Created by longxdragon on 2016/12/28.
//  Copyright © 2016年 longxdragon. All rights reserved.
//

#import "NSObject+DDRouter.h"
#import <objc/runtime.h>

typedef NS_ENUM (NSInteger, DDRouterEncodingType) {
    DDRouterEncodingTypeUnknown = 0,
    DDRouterEncodingTypeNSString,
    DDRouterEncodingTypeBool,
    DDRouterEncodingTypeNumber,
    DDRouterEncodingTypeInt8,
    DDRouterEncodingTypeUInt8,
    DDRouterEncodingTypeInt16,
    DDRouterEncodingTypeUInt16,
    DDRouterEncodingTypeInt32,
    DDRouterEncodingTypeUInt32,
    DDRouterEncodingTypeInt64,
    DDRouterEncodingTypeUInt64,
    DDRouterEncodingTypeFloat,
    DDRouterEncodingTypeDouble,
    DDRouterEncodingTypeLongDouble
};


DDRouterEncodingType DDRouterEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return DDRouterEncodingTypeUnknown;
    size_t len = strlen(typeEncoding);
    if (len == 0) return DDRouterEncodingTypeUnknown;
    
    len = strlen(type);
    if (len == 0) return DDRouterEncodingTypeUnknown;
    
    switch (*type) {
        case 'B': return DDRouterEncodingTypeBool;
        case 'c': return DDRouterEncodingTypeInt8;
        case 'C': return DDRouterEncodingTypeUInt8;
        case 's': return DDRouterEncodingTypeInt16;
        case 'S': return DDRouterEncodingTypeUInt16;
        case 'i': return DDRouterEncodingTypeInt32;
        case 'I': return DDRouterEncodingTypeUInt32;
        case 'l': return DDRouterEncodingTypeInt32;
        case 'L': return DDRouterEncodingTypeUInt32;
        case 'q': return DDRouterEncodingTypeInt64;
        case 'Q': return DDRouterEncodingTypeUInt64;
        case 'f': return DDRouterEncodingTypeFloat;
        case 'd': return DDRouterEncodingTypeDouble;
        case 'D': return DDRouterEncodingTypeLongDouble;
        case '@': {
            NSString *t = [NSString stringWithUTF8String:type];
            if ([@"@\"NSString\"" isEqualToString:t]) {
                return DDRouterEncodingTypeNSString;
            } else {
                return DDRouterEncodingTypeUnknown;
            }
        };
        default: return DDRouterEncodingTypeUnknown;
    }
}


@interface DDRouterObjectPropertyMeta : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) DDRouterEncodingType encodingType;
@end

@implementation DDRouterObjectPropertyMeta
@end

@implementation NSObject (DDRouter)

- (void)router_setPropertiesByDictionary:(NSDictionary *)params {
    for (NSString *key in params.allKeys) {
        id value = params[key];
        DDRouterObjectPropertyMeta *property = [[self class] checkIsExistPropertyWithInstance:[self class] verifyPropertyName:key];
        if (value && property) {
            switch (property.encodingType) {
                case DDRouterEncodingTypeUnknown: {
                    [self setValue:value forKey:key];
                } break;
                case DDRouterEncodingTypeNumber:
                case DDRouterEncodingTypeNSString: {
                    [self setValue:value forKey:key];
                } break;
                case DDRouterEncodingTypeBool: {
                    [self setValue:@([value boolValue]) forKey:key];
                } break;
                case DDRouterEncodingTypeInt8:
                case DDRouterEncodingTypeUInt8:
                case DDRouterEncodingTypeInt16:
                case DDRouterEncodingTypeUInt16:
                case DDRouterEncodingTypeInt32:
                case DDRouterEncodingTypeUInt32:
                case DDRouterEncodingTypeInt64:
                case DDRouterEncodingTypeUInt64: {
                    [self setValue:@([value integerValue]) forKey:key];
                } break;
                case DDRouterEncodingTypeFloat: {
                    [self setValue:@([[value description] floatValue]) forKey:key];
                } break;
                case DDRouterEncodingTypeDouble: {
                    [self setValue:@([[value description] doubleValue]) forKey:key];
                } break;
                case DDRouterEncodingTypeLongDouble: {
                    [self setValue:@([[value description] longLongValue]) forKey:key];
                } break;
                default: break;
            }
        }
    }
}

+ (DDRouterObjectPropertyMeta *)checkIsExistPropertyWithInstance:(Class)class verifyPropertyName:(NSString *)verifyPropertyName {
    if (!class) return nil;
    unsigned int count, i;
    objc_property_t *properties = class_copyPropertyList(class, &count);
    
    for (i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if ([propertyName isEqualToString:verifyPropertyName]) {
            //类别
            DDRouterEncodingType type = 0;
            unsigned int attrCount;
            objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
            for (unsigned int i = 0; i < attrCount; i++) {
                switch (attrs[i].name[0]) {
                    case 'T': {
                        if (attrs[i].value) {
                            type = DDRouterEncodingGetType(attrs[i].value);
                        }
                    }
                    default: break;
                }
            }
            if (attrs) {
                free(attrs);
                attrs = NULL;
            }
            DDRouterObjectPropertyMeta *property = [[DDRouterObjectPropertyMeta alloc] init];
            property.name = propertyName;
            property.encodingType = type;
            
            free(properties);
            return property;
        }
    }
    free(properties);
    return [self checkIsExistPropertyWithInstance:[class superclass] verifyPropertyName:verifyPropertyName];
}

@end
