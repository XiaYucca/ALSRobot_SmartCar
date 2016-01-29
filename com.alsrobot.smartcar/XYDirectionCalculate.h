//
//  XYDirectionCalculate.h
//  XYCoreBlueToothDemo
//
//  Created by RainPoll on 16/1/4.
//  Copyright © 2016年 RainPoll. All rights reserved.
//

#ifndef XYDirectionCalculate_h
#define XYDirectionCalculate_h

#include <stdio.h>
#include <CoreGraphics/CoreGraphics.h>
#include <math.h>


typedef enum{
    origin,
    left,
    leftUp,
    up,
    rightUp,
    right,
    rightDown,
    down,
    leftDown,
}deriction;

CGPoint getLocationWithTranslation(CGPoint center, CGPoint translation, CGFloat minRadius, CGFloat maxRadius);

deriction getDeriction(CGFloat angle);

CGFloat getAngleWithVector(CGPoint translation);

CGFloat getAngleWithPoint(CGPoint center, CGPoint translate);

bool touchRingWithPoint(CGPoint center, CGFloat minRadius, CGFloat maxRadius, CGPoint touchPoint);

#endif /* XYDirectionCalculate_h */
