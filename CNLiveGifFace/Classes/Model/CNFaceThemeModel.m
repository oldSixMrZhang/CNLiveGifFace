//
//  CNFaceThemeModel.m
//  CNLiveNetAdd
//
//  Created by CNLive-zxw on 2018/10/15.
//  Copyright © 2018年 cnlive. All rights reserved.
//

#import "CNFaceThemeModel.h"
@interface CNFaceModel()<NSCoding>

@end

@implementation CNFaceModel
- (void)encodeWithCoder:(NSCoder *)enCoder{

}
- (id)initWithCoder:(NSCoder *)decoder{
    self = [super init];
    if(self){
        
    }
    return self;
}

@end

@implementation CNFaceThemeModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", self.themeIcon, self.themeDesc];
}
+ (NSDictionary *)mj_objectClassInArray{
    return @{
             @"faceModels" : @"CNFaceModel"
             };
}
+(NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"faceModels":@"faces"};
}
@end
