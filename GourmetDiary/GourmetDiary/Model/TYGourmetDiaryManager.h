//
//  TYGourmetDiaryManager.h
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/12.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ShopMst;

typedef void (^Callback)(NSArray *);
typedef void (^SetData)(ShopMst *);

@interface TYGourmetDiaryManager : NSObject

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjetModel;

+ (TYGourmetDiaryManager *)sharedmanager;
- (void)addData:(NSDictionary *)data;
- (void)resetData;
- (NSArray *)fetchData;
- (void)addKeywordSearchData:(NSDictionary *)data;
- (void)fetchKeywordSearchData:(Callback)callback;
- (void)resetKeywordSearchData;
- (void)tempShopData:(NSDictionary *)data setData:(SetData)setData;
- (void)addShopMstData:(ShopMst *)data;
- (void)addVisitData:(NSMutableDictionary *)data;
- (BOOL)addVisitRegist:(NSMutableDictionary *)data shop:(ShopMst *)shop;
- (NSMutableArray *)fetchVisitData;

//1125
- (NSMutableArray *)fetchVisitedList;

@end
