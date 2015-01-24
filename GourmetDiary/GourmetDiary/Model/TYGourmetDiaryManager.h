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
typedef void (^DetailData)(NSArray *);

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
- (BOOL)addVisitRegist:(NSMutableDictionary *)data shop:(ShopMst *)shop;
- (NSMutableArray *)fetchVisitData;
- (BOOL)addShopMstData:(ShopMst *)data;
- (BOOL)addVisitData:(NSMutableDictionary *)data;
- (BOOL)editorRegist:(NSMutableDictionary *)data;
- (NSMutableArray *)fetchVisitedList:(NSInteger)set num:(NSInteger)num;
- (NSInteger)fetchVisitCount:(NSString *)sid;
- (NSInteger)fetchShopLevel:(NSString *)sid;
- (NSMutableArray *)fetchMasterData:(NSInteger)num;
- (void)fetchShopMasterData:(NSString *)sid callback:(Callback)callback;
- (NSMutableArray *)fetchDiaryData:(id)oid;
- (BOOL)fetchDetailData:(NSString *)sid detailData:(DetailData)detailData;
- (BOOL)deleteDiary:(id)oid;

//0112
- (NSInteger)fetchMasterCount;

@end
