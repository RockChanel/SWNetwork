#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SWBatchChainRequest.h"
#import "SWBatchRequest.h"
#import "SWChainRequest.h"
#import "SWFileManager.h"
#import "SWNetwork.h"
#import "SWNetworkAgent.h"
#import "SWNetworkConfiguration.h"
#import "SWNetworkManager.h"
#import "SWRequest.h"

FOUNDATION_EXPORT double SWNetworkVersionNumber;
FOUNDATION_EXPORT const unsigned char SWNetworkVersionString[];

