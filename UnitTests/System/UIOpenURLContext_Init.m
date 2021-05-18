//
//  UIOpenURLContext_Init.m
//  UnitTests
//
//  Created by Alexey on 18.05.2021.
//  Copyright © 2021 Alexey Naumov. All rights reserved.
//

#import "UIOpenURLContext_Init.h"

@implementation UIOpenURLContext (Init)

+ (instancetype)createInstance {
    NSString *name = NSStringFromClass([self class]);
    return [[NSClassFromString(name) alloc] init];
}

@end
