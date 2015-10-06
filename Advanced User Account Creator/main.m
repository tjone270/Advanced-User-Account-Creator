//
//  main.m
//  Advanced User Account Creator
//
//  Created by Thomas Jones on 16/05/2014.
//  Copyright (c) 2014 TomTec Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <AppleScriptObjC/AppleScriptObjC.h>

int main(int argc, const char * argv[])
{
    [[NSBundle mainBundle] loadAppleScriptObjectiveCScripts];
    return NSApplicationMain(argc, argv);
}
