//
//  TYGourmetDialyManager.m
//  GourmetDiary
//
//  Created by Tomohiko on 2014/11/12.
//  Copyright (c) 2014年 yamatomo. All rights reserved.
//

#import "TYGourmetDiaryManager.h"
#import "SearchData.h"
#import "KeywordSearch.h"
#import "ShopMst.h"
#import "VisitData.h"

@implementation TYGourmetDiaryManager {
  SearchData *_searchData;
  KeywordSearch *_keywordData;
  ShopMst *_shopData;
  VisitData *_visitData;
  NSURL *_storeURL;
  int _n;
  NSDateFormatter *_dateFomatter;
  NSManagedObjectID *_oId;
}

static NSManagedObject *master;
static NSManagedObject *visit;
static TYGourmetDiaryManager *sharedInstance = nil;

+ (TYGourmetDiaryManager *)sharedmanager
{
  @synchronized(self) {
    LOG()
    sharedInstance = [[self alloc] init];
  }
  return sharedInstance;
}

- (id)init
{
  self = [super init];
  if (self) {
    //初期設定
    _dateFomatter = [[NSDateFormatter alloc] init];
   [_dateFomatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
   [_dateFomatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
    [self loadManagedObjectContext];
  }
  return self;
}

- (void)loadManagedObjectContext
{
  if (self.context != nil) return;
  NSPersistentStoreCoordinator *aCoodinator = [self coordinator];
  if (aCoodinator != nil) {
    self.context = [[NSManagedObjectContext alloc] init];
    [self.context setPersistentStoreCoordinator:aCoodinator];
    self.context.undoManager = [[NSUndoManager alloc] init];
  }
}

- (NSPersistentStoreCoordinator *)coordinator
{
  if (_coordinator != nil) {
    return _coordinator;
  }
// SQLパターン
  NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  _storeURL = [NSURL fileURLWithPath:[directory stringByAppendingPathComponent:@"GourmetDiary.sqlite"]];
//  LOG(@"storeURL %@", _storeURL)
//  NSURL *modelURL = [NSURL fileURLWithPath:[NSFileManager defaultManager].currentDirectoryPath];
//  modelURL = [modelURL URLByAppendingPathComponent:@"GourmetDiary.momd"];
  NSError *error = nil;
  _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjetModel]];
  if (![_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:_storeURL options:nil error:&error]) {
    LOG(@"Unresolved error %@ %@", error, [error userInfo])
    abort();
  }
  return _coordinator;
}

- (NSManagedObjectModel *)managedObjetModel {
  if (_managedObjetModel != nil) {
    return _managedObjetModel;
  }
  NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"GourmetDiary" ofType:@"momd"];
  NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
//  LOG(@"modelURL %@  %@", modelPath, modelURL)
  _managedObjetModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  
  return _managedObjetModel;
}

#pragma mark - TYSearchViewController
/* 検索TOP・現在地検索 */
//データリセット
- (void)resetData
{
  LOG()
  if (_searchData) {
    [self.context deleteObject:_searchData];
    NSError *error;
    if (![self.context save:&error]) {
      LOG(@"error: %@", error)
    }
  } else {
    NSFetchRequest *requestDelete = [[NSFetchRequest alloc] init];
    [requestDelete setEntity:[NSEntityDescription entityForName:@"SearchData" inManagedObjectContext:self.context]];
    [requestDelete setIncludesPropertyValues:NO];
    NSError *error = nil;
    NSArray *dataArray = [self.context executeFetchRequest:requestDelete error:&error];
    for (NSManagedObject *data in dataArray) {
      [self.context deleteObject:data];
    }
    NSError *saveError = nil;
    [self.context save:&saveError];
  }
}

//ロケーションデータ登録
- (void)addData:(NSDictionary *)data
{
  NSArray *ary = [[data objectForKey:@"results"] objectForKey:@"shop"];
  LOG(@"data: %lu", ary.count)
  
  for (_n = 0; _n < ary.count; _n++) {
    _searchData = (SearchData *)[NSEntityDescription insertNewObjectForEntityForName:@"SearchData" inManagedObjectContext:self.context];
    if (_searchData == nil) {
      return;
    }
    _searchData.shop = [[data valueForKeyPath:@"results.shop.name"] objectAtIndex:_n];
    _searchData.sid = [[data valueForKeyPath:@"results.shop.id"] objectAtIndex:_n];
    _searchData.genre = [[data valueForKeyPath:@"results.shop.genre.name"] objectAtIndex:_n];
    _searchData.area = [[data valueForKeyPath:@"results.shop.small_area.name"] objectAtIndex:_n];
    NSString *lat = [[data valueForKeyPath:@"results.shop.lat"] objectAtIndex:_n];
    _searchData.lat = [NSNumber numberWithDouble:[lat doubleValue]];
    NSString *lng = [[data valueForKeyPath:@"results.shop.lng"] objectAtIndex:_n];
    _searchData.lng = [NSNumber numberWithDouble:[lng doubleValue]];
    LOG(@"n %d shop: %@ sid: %@ genru:%@ area:%@ lat:%@ lng:%@", _n, _searchData.shop, _searchData.sid, _searchData.genre, _searchData.area, _searchData.lat, _searchData.lng)
    NSError *error = nil;
    if (![self.context save:&error]) {
      LOG("error %@", error)
    }
  }
}

//検索TOPデータ取得
- (NSArray *)fetchData
{
  NSError *error = nil;
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SearchData"];
  NSArray *fetchedArray = [_context executeFetchRequest:request error:&error];
  LOG(@"fetch count %lu", fetchedArray.count)
  if (fetchedArray == nil) {
    LOG(@"fetch failure\n%@", [error localizedDescription])
    return fetchedArray;
  }
  return fetchedArray;
}

#pragma mark - TYResultViewController
/* キーワード検索 */
//キーワード検索データリセット
- (void)resetKeywordSearchData
{
  LOG()
  if (_keywordData) {
    [self.context deleteObject:_keywordData];
    NSError *error;
    if (![self.context save:&error]) {
      LOG(@"error: %@", error)
    }
  } else {
    NSFetchRequest *requestDelete = [[NSFetchRequest alloc] init];
    [requestDelete setEntity:[NSEntityDescription entityForName:@"KeywordSearch" inManagedObjectContext:self.context]];
    [requestDelete setIncludesPropertyValues:NO];
    NSError *error = nil;
    NSArray *dataArray = [self.context executeFetchRequest:requestDelete error:&error];
    for (NSManagedObject *data in dataArray) {
      [self.context deleteObject:data];
    }
    NSError *saveError = nil;
    [self.context save:&saveError];
  }
}

//キーワード検索結果登録
- (void)addKeywordSearchData:(NSDictionary *)data
{
  NSArray *ary = [[data objectForKey:@"results"] objectForKey:@"shop"];
  LOG(@"data: %lu", ary.count)
  
  for (_n = 0; _n < ary.count; _n++) {
    _keywordData = (KeywordSearch *)[NSEntityDescription insertNewObjectForEntityForName:@"KeywordSearch" inManagedObjectContext:self.context];
    if (_keywordData == nil) {
      return;
    }
    _keywordData.shop = [[data valueForKeyPath:@"results.shop.name"] objectAtIndex:_n];
    _keywordData.sid = [[data valueForKeyPath:@"results.shop.id"] objectAtIndex:_n];
    _keywordData.genre = [[data valueForKeyPath:@"results.shop.genre.name"] objectAtIndex:_n];
    _keywordData.area = [[data valueForKeyPath:@"results.shop.small_area.name"] objectAtIndex:_n];
    LOG(@"n %d shop: %@ sid: %@ genre:%@ area:%@", _n, _keywordData.shop, _keywordData.sid, _keywordData.genre, _keywordData.area)
    NSError *error = nil;
    if (![self.context save:&error]) {
      LOG("error %@", error)
    }
  }
}

//検索TOPデータ取得
- (void)fetchKeywordSearchData:(Callback)callback
{
  LOG()
  NSError *error = nil;
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"KeywordSearch"];
  NSArray *fetchedArray = [self.context executeFetchRequest:request error:&error];
  
  if (fetchedArray == nil) {
    LOG(@"fetch failure\n%@", [error localizedDescription])
  }
  
  if (callback) {
    LOG()
    callback(fetchedArray);
  }
}

#pragma mark - TYDetailViewController
/* shop詳細 */
- (void)tempShopData:(NSDictionary *)data setData:(SetData)setData
{
  _shopData = nil;
//  NSArray *ary = [[data objectForKey:@"results"] objectForKey:@"shop"];
//  LOG(@"data: %lu", ary.count)
  
  _shopData = (ShopMst *)[NSEntityDescription insertNewObjectForEntityForName:@"ShopMst" inManagedObjectContext:self.context];
  if (_shopData == nil) {
    return;
  } else {
    LOG()
    _shopData.shop = [[data valueForKeyPath:@"results.shop.name"] objectAtIndex:0];
    _shopData.shop_kana = [[data valueForKeyPath:@"results.shop.name"] objectAtIndex:0];
    _shopData.area = [[data valueForKeyPath:@"results.shop.small_area.name"] objectAtIndex:0];
    _shopData.address = [[data valueForKeyPath:@"results.shop.address"] objectAtIndex:0];
    _shopData.genre = [[data valueForKeyPath:@"results.shop.genre.name"] objectAtIndex:0];
    _shopData.url = [[data valueForKeyPath:@"results.shop.urls.mobile"] objectAtIndex:0];
    _shopData.sp_url = [[data valueForKeyPath:@"results.shop.coupon_urls.sp"] objectAtIndex:0];
    NSString *lat = [[data valueForKeyPath:@"results.shop.lat"] objectAtIndex:0];
    _shopData.lat = [NSNumber numberWithDouble:[lat doubleValue]];
    NSString *lng = [[data valueForKeyPath:@"results.shop.lng"] objectAtIndex:0];
    _shopData.lng = [NSNumber numberWithDouble:[lng doubleValue]];
    _shopData.img_path = [[data valueForKeyPath:@"results.shop.photo.mobile.l"] objectAtIndex:0];
    _shopData.sid = [[data valueForKeyPath:@"results.shop.id"] objectAtIndex:0];
    
//    LOG(@"shop:%@ shop_kana:%@ area:%@ address:%@ genre:%@ url:%@ sp_url:%@ lat:%@ lng:%@ img_path:%@ sid:%@", _shopData.shop, _shopData.shop_kana, _shopData.area, _shopData.address, _shopData.genre, _shopData.url, _shopData.sp_url, _shopData.lat, _shopData.lng, _shopData.img_path, _shopData.sid)
    
  }
  
//  NSArray *visitAry = [self fetchVisitData];
  
  if (setData) {
    LOG()
    setData(_shopData);
  }
}

- (NSInteger)fetchVisitCount:(NSString *)sid
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"VisitData" inManagedObjectContext:self.context];
  [request setEntity:entity];
  LOG(@"data sid %@", sid)
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"sid = %@",sid];
  [request setPredicate:pred];
  [request setIncludesSubentities:NO];
  
  NSError *error = nil;
  if (error) {
    LOG(@"error %@ %@", error, [error userInfo])
    return NO;
  }
  NSUInteger cnt = [self.context countForFetchRequest:request error:&error];
  return cnt;
}

- (NSInteger)fetchShopLevel:(NSString *)sid
{
  LOG()
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShopMst" inManagedObjectContext:self.context];
  [request setEntity:entity];
  [request setResultType:NSDictionaryResultType];
  [request setIncludesSubentities:NO];
  [request setPropertiesToFetch:@[@"level"]];
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"sid = %@",sid];
  [request setPredicate:pred];
  
  NSError *error = nil;
  if (error) {
    LOG(@"error %@ %@", error, [error userInfo])
    return NO;
  }
  NSArray *moArray = [self.context executeFetchRequest:request error:&error];
  return moArray.count;
}


#pragma mark - TYRegisterViewController
//店舗マスター登録
- (BOOL)addShopMstData:(ShopMst *)data
{
  _shopData = nil;
  master = nil;
  
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShopMst" inManagedObjectContext:self.context];
  [request setEntity:entity];
  LOG(@"data sid %@", data.sid)
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"sid = %@",data.sid];
//  LOG(@"sid: %@", data.sid)
  [request setPredicate:pred];
  NSError *error = nil;
  
  if (error) {
    LOG(@"error %@ %@", error, [error userInfo])
    return NO;
  }
  
  NSArray *moArray = [self.context executeFetchRequest:request error:&error];
  master = [NSEntityDescription insertNewObjectForEntityForName:@"ShopMst" inManagedObjectContext:self.context];
  LOG(@"moArray count:%lu", moArray.count)
  LOG(@"moArray count:%@", moArray)
  
  if (moArray.count == 0) {
    LOG(@"新規登録")
    if (master == nil) {
      LOG(@"master null")
      return NO;
    }
    NSString *dateStr = [_dateFomatter stringFromDate:[NSDate date]];
    [_dateFomatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
    NSDate *date = [_dateFomatter dateFromString:dateStr];
    [master setValue:date forKey:@"updated_at"];
    [master setValue:date forKey:@"created_at"];
    [master setValue:data.shop forKey:@"shop"];
    [master setValue:data.shop_kana forKey:@"shop_kana"];
    [master setValue:data.area forKey:@"area"];
    [master setValue:data.address forKey:@"address"];
    [master setValue:data.genre forKey:@"genre"];
    [master setValue:data.url forKey:@"url"];
    [master setValue:data.sp_url forKey:@"sp_url"];
    [master setValue:data.lat forKey:@"lat"];
    [master setValue:data.lng forKey:@"lng"];
    [master setValue:data.img_path forKey:@"img_path"];
    [master setValue:data.level forKey:@"level"];
    [master setValue:data.sid forKey:@"sid"];
    
//    LOG(@"shop:%@ shop_kana:%@ area:%@ address:%@ genre:%@ url:%@ sp_url:%@ lat:%@ lng:%@ img_path:%@ sid:%@ level:%@", data.shop, data.shop_kana, data.area, data.address, data.genre, data.url, data.sp_url, data.lat, data.lng, data.img_path, data.sid, data.level)
    
  } else {
    LOG(@"上書き")
    master = [moArray objectAtIndex:0];
    LOG(@"master: %@", [master valueForKey:@"shop"])
    NSString *dateStr = [_dateFomatter stringFromDate:[NSDate date]];
    [_dateFomatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
    NSDate *date = [_dateFomatter dateFromString:dateStr];
    [master setValue:date forKey:@"updated_at"];
    [master setValue:data.shop forKey:@"shop"];
    [master setValue:data.shop_kana forKey:@"shop_kana"];
    [master setValue:data.area forKey:@"area"];
    [master setValue:data.address forKey:@"address"];
    [master setValue:data.genre forKey:@"genre"];
    [master setValue:data.url forKey:@"url"];
    [master setValue:data.sp_url forKey:@"sp_url"];
    [master setValue:data.lat forKey:@"lat"];
    [master setValue:data.lng forKey:@"lng"];
    [master setValue:data.img_path forKey:@"img_path"];
    [master setValue:data.level forKey:@"level"];
//    LOG(@"updateObj: %@", updateObj)
  }
  NSError *saveError = nil;
  if (![self.context save:&saveError]) {
    LOG("error %@ %@", error, saveError)
    return NO;
  }
  return YES;
}

#pragma mark - TYRegisterViewController
/* 利用記録データ */
//Register
- (BOOL)addVisitRegist:(NSMutableDictionary *)data shop:(ShopMst *)shop
{
  LOG(@"data: %@ shop: %@", data, shop)
  if (![self addShopMstData:shop]) {
    return NO;
  }
  if (![self addVisitData:data]) {
    return NO;
  }
  return YES;
}

#pragma mark - TYEditorViewController
//Editor
- (BOOL)editorRegist:(NSMutableDictionary *)data
{
  if ([data valueForKey:@"new"]) {
//    LOG(@"data genre: %@", [data valueForKey:@"genre"])
    master = nil;
    master = [NSEntityDescription insertNewObjectForEntityForName:@"ShopMst" inManagedObjectContext:self.context];
//    master = (ShopMst *)[NSEntityDescription insertNewObjectForEntityForName:@"ShopMst" inManagedObjectContext:self.context];
    [master setValue:[data valueForKey:@"sid"] forKey:@"sid"];
    [master setValue:[data valueForKey:@"shop"] forKey:@"shop"];
    [master setValue:[data valueForKey:@"genre"] forKey:@"genre"];
    [master setValue:[data valueForKey:@"level"] forKey:@"level"];
    [master setValue:[data valueForKey:@"area"] forKey:@"area"];
    NSError *saveError = nil;
    
    if (![self.context save:&saveError]) {
      LOG("error %@", saveError)
      return NO;
    }
    
//    if (![self addShopMstData:shop]) {
//      LOG(@"shop master commit NG")
//      return NO;
//    }
    if (![self addVisitData:data]) {
      LOG(@"visit data commit NG")
      return NO;
    }
  } else {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShopMst" inManagedObjectContext:self.context];
    [request setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"sid = %@",[data valueForKey:@"sid"]];
    [request setPredicate:pred];
    
    NSError *error = nil;
    if (error) {
      LOG(@"error %@ %@", error, [error userInfo])
      return NO;
    }
    
    NSArray *moArray = [self.context executeFetchRequest:request error:&error];
    master = [NSEntityDescription insertNewObjectForEntityForName:@"ShopMst" inManagedObjectContext:self.context];
    if (!moArray.count == 0) {
      if (master == nil) {
        LOG(@"master null")
        return NO;
      }
      master = [moArray objectAtIndex:0];
      [master setValue:[data valueForKey:@"level"] forKey:@"level"];
      NSError *saveError = nil;
      if (![self.context save:&saveError]) {
        LOG("error %@ %@", error, saveError)
        return NO;
      }
      
      if (![self updateVisitData:data]) {
        LOG(@"visit data commit NG")
        return NO;
      }
    } else {
      LOG(@"no data error")
      return NO;
    }
  }
  return YES;
}

#pragma mark - TYRegisterViewController
#pragma mark - TYEditorViewController
- (BOOL)addVisitData:(NSMutableDictionary *)data
{
  LOG(@"data %@", data)
  visit = [NSEntityDescription insertNewObjectForEntityForName:@"VisitData" inManagedObjectContext:self.context];
  if (visit == nil) {
    [self undo];
    return NO;
  }
  NSString *dateStr = [_dateFomatter stringFromDate:[NSDate date]];
  [_dateFomatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
  NSDate *date = [_dateFomatter dateFromString:dateStr];
  [visit setValue:date forKey:@"updated_at"];
  [visit setValue:date forKey:@"created_at"];
  [visit setValue:[data valueForKey:@"sid"] forKey:@"sid"];
  [visit setValue:[data valueForKey:@"visited_at"] forKey:@"visited_at"];
  [visit setValue:[data valueForKey:@"memo"] forKey:@"memo"];
  [visit setValue:[data valueForKey:@"situation"] forKey:@"situation"];
  [visit setValue:[data valueForKey:@"fee"] forKey:@"fee"];
  [visit setValue:[data valueForKey:@"persons"] forKey:@"persons"];
  
//  LOG(@"sid:%@ visited_at:%@ memo:%@ situation:%@ fee:%@ persons:%@ created_at:%@ updated_at:%@", _visitData.sid, _visitData.visited_at, _visitData.memo, _visitData.situation, _visitData.fee, _visitData.persons, _visitData.created_at, _visitData.updated_at)
  
  [visit setValue:[NSSet setWithArray:@[master]] forKey:@"diary"];
  
  NSError *error = nil;
  if (![_context save:&error]) {
    [self undo];
    LOG("error %@", error)
    return NO;
  }
  return YES;
}

#pragma mark - TYEditorViewController
//訪問記録の上書き
- (BOOL)updateVisitData:(NSMutableDictionary *)data
{
  LOG(@"data %@", data)
  
  VisitData *editor = (VisitData *)[self.context objectWithID:_oId];
  
  LOG(@"editor:%@", editor)
  if (editor == nil) {
    LOG(@"editor null")
    return NO;
  }
//  visit = [NSEntityDescription insertNewObjectForEntityForName:@"VisitData" inManagedObjectContext:self.context];
  if (editor == nil) {
    [self undo];
    return NO;
  }
  
  NSString *dateStr = [_dateFomatter stringFromDate:[NSDate date]];
  [_dateFomatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
  NSDate *date = [_dateFomatter dateFromString:dateStr];
  [editor setValue:date forKey:@"updated_at"];
  [editor setValue:[data valueForKey:@"visited_at"] forKey:@"visited_at"];
  [editor setValue:[data valueForKey:@"memo"] forKey:@"memo"];
  [editor setValue:[data valueForKey:@"situation"] forKey:@"situation"];
  [editor setValue:[data valueForKey:@"fee"] forKey:@"fee"];
  [editor setValue:[data valueForKey:@"persons"] forKey:@"persons"];
  
//  LOG(@"sid:%@ visited_at:%@ memo:%@ situation:%@ fee:%@ persons:%@ created_at:%@ updated_at:%@", _visitData.sid, _visitData.visited_at, _visitData.memo, _visitData.situation, _visitData.fee, _visitData.persons, _visitData.created_at, _visitData.updated_at)
  
  [editor setValue:[NSSet setWithArray:@[master]] forKey:@"diary"];
  
  NSError *error = nil;
  if (![_context save:&error]) {
    [self undo];
    LOG("error %@", error)
    return NO;
  }
  return YES;
}

#pragma mark - TYViewController
//Top
- (NSMutableArray *)fetchVisitData
{
  NSMutableArray *array = [NSMutableArray array];
  NSError *error = nil;
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VisitData"];
  [request setFetchLimit:2];
  NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"visited_at" ascending:NO];
  request.sortDescriptors = @[sort];
  NSArray *fetchedArray = [_context executeFetchRequest:request error:&error];
  
  if (fetchedArray == nil) {
    LOG(@"fetch failure\n%@", [error localizedDescription])
    return array;
  }
  for (NSManagedObject *obj in fetchedArray) {
    NSMutableDictionary *ary = [NSMutableDictionary dictionary];
    [ary setValue:[obj valueForKey:@"visited_at"] forKey:@"visited"];
//    LOG(@"visit: %@", [obj valueForKey:@"visited_at"])
    NSSet *master = [obj valueForKey:@"diary"];
    if (master.count == 0) {
      LOG(@"null");
    } else {
      for (NSManagedObject *shop in master) {
        LOG(@"shop: %@", [shop valueForKey:@"shop"])
        [ary setValue:[shop valueForKey:@"shop"] forKey:@"shop"];
        [ary setValue:[shop valueForKey:@"sid"] forKey:@"sid"];
        [ary setValue:[shop valueForKey:@"level"] forKey:@"level"];
        [ary setValue:[shop valueForKey:@"genre"] forKey:@"genre"];
        [ary setValue:[shop valueForKey:@"area"] forKey:@"area"];
      }
    }
    [array addObject:ary];
    
  }
  return array;
}

#pragma mark - TYDiaryViewController
/* 日記リスト */
- (NSMutableArray *)fetchVisitedList:(NSInteger)set num:(NSInteger)num
{
  LOG(@"set:%lu set:%lu", set, num)
  NSMutableArray *array = [NSMutableArray array];
  NSError *error = nil;
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VisitData"];
  NSInteger count = [self.context countForFetchRequest:request error:&error];
  request.fetchLimit = num;
  NSSortDescriptor *sort;
  if (set == 1) {
    sort = [[NSSortDescriptor alloc] initWithKey:@"visited_at" ascending:NO];
  } else if (set == 2) {
    sort = [[NSSortDescriptor alloc] initWithKey:@"visited_at" ascending:YES];
  }
  request.sortDescriptors = @[sort];
  NSArray *fetchedArray = [_context executeFetchRequest:request error:&error];
  if (fetchedArray == nil) {
    LOG(@"fetch failure\n%@", [error localizedDescription])
    return array;
  }
  for (NSManagedObject *obj in fetchedArray) {
    NSMutableDictionary *ary = [NSMutableDictionary dictionary];
    [ary setValue:[obj valueForKey:@"visited_at"] forKey:@"visited"];
    [ary setValue:[obj valueForKey:@"memo"] forKey:@"comment"];
    NSSet *master = [obj valueForKey:@"diary"];
    if (master.count == 0) {
      LOG(@"null");
    } else {
      for (NSManagedObject *shop in master) {
        [ary setValue:[shop valueForKey:@"shop"] forKey:@"shop"];
        [ary setValue:[shop valueForKey:@"genre"] forKey:@"genre"];
        [ary setValue:[shop valueForKey:@"level"] forKey:@"level"];
        [ary setValue:[shop valueForKey:@"area"] forKey:@"area"];
        [ary setValue:[shop valueForKey:@"sid"] forKey:@"sid"];
        [ary setValue:[NSNumber numberWithInteger:count] forKey:@"count"];
      }
    }
    [array addObject:ary];
    
  }
  return array;
}

- (NSMutableArray *)fetchDiaryData:(NSString *)para
{
  NSMutableArray *array = [NSMutableArray array];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"VisitData" inManagedObjectContext:self.context];
  [request setEntity:entity];
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"sid = %@",para];
  [request setPredicate:pred];
  NSError *error = nil;
  if (error) {
    LOG(@"error %@ %@", error, [error userInfo])
  }
  NSArray *moArray = [self.context executeFetchRequest:request error:&error];
  _oId = nil;
  for (NSManagedObject *obj in moArray) {
    _oId = [obj objectID];
    NSMutableDictionary *ary = [NSMutableDictionary dictionary];
    [ary setValue:[obj valueForKey:@"visited_at"] forKey:@"visited_at"];
    [ary setValue:[obj valueForKey:@"situation"] forKey:@"situation"];
    [ary setValue:[obj valueForKey:@"persons"] forKey:@"persons"];
    [ary setValue:[obj valueForKey:@"fee"] forKey:@"fee"];
    [ary setValue:[obj valueForKey:@"memo"] forKey:@"memo"];
//    [ary setValue:_oId forKey:@"oid"];
    NSSet *master = [obj valueForKey:@"diary"];
    if (master.count == 0) {
      LOG(@"null");
    } else {
      for (NSManagedObject *shop in master) {
        [ary setValue:[shop valueForKey:@"shop"] forKey:@"shop"];
        [ary setValue:[shop valueForKey:@"level"] forKey:@"level"];
      }
    }
    [array addObject:ary];
  }
  return array;
}

- (BOOL)deleteDiary
{
  LOG(@"_oid %@", _oId)
  NSManagedObject *deleteObj = [self.context objectWithID:_oId];
  [self.context deleteObject:deleteObj];
  if (![self save]) {
    return NO;
  }
  return YES;
}

- (void)undo
{
  LOG()
  [self.context undo];
  NSError *error = nil;
  if (![self.context save:&error]) {
    LOG(@"error: %@", error);
  }
}

- (BOOL)save
{
  NSError *error = nil;
  if (![self.context save:&error]) {
    LOG(@"error: %@", error);
    return NO;
  }
  return YES;
}

/*test*/
//- (void)testFetch
//{
//  NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"VisitData"];
//  NSError *error = nil;
//  NSArray *ary = [self.context executeFetchRequest:req error:&error];
//  if (ary == nil) {
//    LOG(@"error %@", error)
//  }
//  LOG()
//  for (NSManagedObject *obj in ary) {
//    LOG(@"situ %@", [obj valueForKey:@"situation"])
//    NSSet *master = [obj valueForKey:@"diary"];
//    if (master.count == 0) {
//      LOG(@"null");
//    } else {
//      for (NSManagedObject *shop in master) {
//        LOG(@"shop: %@", [shop valueForKey:@"shop"])
//      }
//    }
//  }
//}

- (void)test2
{
//  NSManagedObject *managedObject = [self.context objectWithID:objID];
}


@end
