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
  NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  _storeURL = [NSURL fileURLWithPath:[directory stringByAppendingPathComponent:@"GourmetDiary.sqlite"]];
//  LOG(@"storeURL %@", _storeURL)
  
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


/* 検索TOP・現在地検索 */
#pragma mark - TYSearchViewController

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
    
//    LOG(@"n %d shop: %@ sid: %@ genru:%@ area:%@ lat:%@ lng:%@", _n, _searchData.shop, _searchData.sid, _searchData.genre, _searchData.area, _searchData.lat, _searchData.lng)
    
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
  if (fetchedArray == nil) {
    LOG(@"fetch failure\n%@", [error localizedDescription])
    return fetchedArray;
  }
  return fetchedArray;
}


/* キーワード検索 */
#pragma mark - TYResultViewController

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
  
  for (_n = 0; _n < ary.count; _n++) {
    _keywordData = (KeywordSearch *)[NSEntityDescription insertNewObjectForEntityForName:@"KeywordSearch" inManagedObjectContext:self.context];
    if (_keywordData == nil) {
      return;
    }
    _keywordData.shop = [[data valueForKeyPath:@"results.shop.name"] objectAtIndex:_n];
    _keywordData.sid = [[data valueForKeyPath:@"results.shop.id"] objectAtIndex:_n];
    _keywordData.genre = [[data valueForKeyPath:@"results.shop.genre.name"] objectAtIndex:_n];
    _keywordData.area = [[data valueForKeyPath:@"results.shop.small_area.name"] objectAtIndex:_n];
//    LOG(@"n %d shop: %@ sid: %@ genre:%@ area:%@", _n, _keywordData.shop, _keywordData.sid, _keywordData.genre, _keywordData.area)
    
    NSError *error = nil;
    if (![self.context save:&error]) {
      LOG("error %@", error)
    }
  }
}

//検索データ取得
- (void)fetchKeywordSearchData:(Callback)callback
{
  NSError *error = nil;
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"KeywordSearch"];
  NSArray *fetchedArray = [self.context executeFetchRequest:request error:&error];
  
  if (fetchedArray == nil) {
    LOG(@"fetch failure\n%@", [error localizedDescription])
  }
  
  if (callback) {
    callback(fetchedArray);
  }
}

/* shop詳細 */
#pragma mark - TYDetailViewController
//検索結果
- (void)tempShopData:(NSDictionary *)data setData:(SetData)setData
{
  _shopData = nil;
  
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
  if (setData) {
    LOG()
    setData(_shopData);
  }
}

//登録詳細
- (BOOL)fetchDetailData:(NSString *)sid detailData:(DetailData)detailData
{
  LOG()
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShopMst" inManagedObjectContext:self.context];
  [request setEntity:entity];
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"sid = %@", sid];
  [request setPredicate:pred];
  NSError *error = nil;
  
  if (error) {
    LOG(@"error %@ %@", error, [error userInfo])
    return NO;
  }
  
  NSArray *moArray = [self.context executeFetchRequest:request error:&error];
  
  if (moArray.count == 0) {
    LOG(@"no data error")
    return NO;
  }
  if (detailData) {
    LOG()
    detailData(moArray);
  }
  return YES;
}

- (NSInteger)fetchVisitCount:(NSString *)sid
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"VisitData" inManagedObjectContext:self.context];
  [request setEntity:entity];
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


/* 利用記録データ */
#pragma mark - TYRegisterViewController

//店舗マスター登録
- (BOOL)addShopMstData:(ShopMst *)data
{
  _shopData = nil;
  master = nil;
  
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShopMst" inManagedObjectContext:self.context];
  [request setEntity:entity];
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"sid = %@",data.sid];
  [request setPredicate:pred];
  NSError *error = nil;
  
  if (error) {
    LOG(@"error %@ %@", error, [error userInfo])
    return NO;
  }
  
  NSArray *moArray = [self.context executeFetchRequest:request error:&error];
  master = [NSEntityDescription insertNewObjectForEntityForName:@"ShopMst" inManagedObjectContext:self.context];
  
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
  }
  NSError *saveError = nil;
  if (![self.context save:&saveError]) {
    LOG("error %@ %@", error, saveError)
    return NO;
  }
  return YES;
}

//利用登録
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

//利用登録　訪問情報
- (BOOL)addVisitData:(NSMutableDictionary *)data
{
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
  
  [visit setValue:[NSSet setWithArray:@[master]] forKey:@"diary"];
  
  NSError *error = nil;
  if (![_context save:&error]) {
    [self undo];
    LOG("error %@", error)
    return NO;
  }
  return YES;
}


/* 編集更新or新規登録 */
#pragma mark - TYEditorViewController

- (BOOL)editorRegist:(NSMutableDictionary *)data
{
  LOG()
  if ([data valueForKey:@"masterAdd"]) {
    LOG()
    master = nil;
    master = [NSEntityDescription insertNewObjectForEntityForName:@"ShopMst" inManagedObjectContext:self.context];
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
    if (![self addVisitData:data]) {
      LOG(@"visit data commit NG")
      return NO;
    }
  } else {
    LOG()
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
    if (!moArray.count == 0) {
      LOG()
      master = [moArray objectAtIndex:0];
      LOG(@"master:%@", master)
      if (master == nil) {
        LOG(@"master null")
        return NO;
      }
      [master setValue:[data valueForKey:@"level"] forKey:@"level"];
      NSError *saveError = nil;
      if (![self.context save:&saveError]) {
        LOG("error %@ %@", error, saveError)
        return NO;
      }
      
      if ([data valueForKey:@"new"]) {
      LOG()
        if (![self addVisitData:data]) {
          LOG(@"visit data commit NG")
          return NO;
        }
      } else {
      LOG()
        if (![self updateVisitData:data]) {
          LOG(@"visit data commit NG")
          return NO;
        }
      }
    } else {
      LOG(@"no data error")
      return NO;
    }
  }
  return YES;
}

//訪問記録の上書き
- (BOOL)updateVisitData:(NSMutableDictionary *)data
{
  LOG(@"data:%@", data)
  VisitData *editor = (VisitData *)[self.context objectWithID:[data valueForKey:@"oid"]];
  LOG(@"editor:%@", editor)
  
  if (editor == nil) {
    LOG(@"editor null")
    return NO;
  }
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
//0104  [editor setValue:[NSSet setWithArray:@[master]] forKey:@"diary"];
  
  NSError *error = nil;
  if (![_context save:&error]) {
    [self undo];
    LOG("error %@", error)
    return NO;
  }
  return YES;
}

//訪問履歴編集時 データ取得
- (NSMutableArray *)fetchDiaryData:(id)oid
{
  LOG(@"oid:%@", oid)
  NSMutableArray *array = [NSMutableArray array];
  VisitData *edtData = (VisitData *)[self.context objectWithID:oid];
  
  NSMutableDictionary *ary = [NSMutableDictionary dictionary];
  [ary setValue:[edtData valueForKey:@"visited_at"] forKey:@"visited_at"];
  [ary setValue:[edtData valueForKey:@"situation"] forKey:@"situation"];
  [ary setValue:[edtData valueForKey:@"persons"] forKey:@"persons"];
  [ary setValue:[edtData valueForKey:@"fee"] forKey:@"fee"];
  [ary setValue:[edtData valueForKey:@"memo"] forKey:@"memo"];
  NSSet *master = [edtData valueForKey:@"diary"];
  if (master.count == 0) {
    LOG(@"null");
  } else {
    for (NSManagedObject *shop in master) {
      [ary setValue:[shop valueForKey:@"shop"] forKey:@"shop"];
      [ary setValue:[shop valueForKey:@"level"] forKey:@"level"];
    }
  }
  LOG(@"ary:%@", ary)
  [array addObject:ary];
  return array;
}
//変更前1231
//- (NSMutableArray *)fetchDiaryData:(NSString *)para oid:(id)oid
//{
//  NSMutableArray *array = [NSMutableArray array];
//  NSFetchRequest *request = [[NSFetchRequest alloc] init];
//  NSEntityDescription *entity = [NSEntityDescription entityForName:@"VisitData" inManagedObjectContext:self.context];
//  [request setEntity:entity];
//  NSPredicate *pred = [NSPredicate predicateWithFormat:@"sid = %@",para];
//  [request setPredicate:pred];
//  NSError *error = nil;
//  NSArray *moArray = [self.context executeFetchRequest:request error:&error];
//  if (error) {
//    LOG(@"error %@ %@", error, [error userInfo])
//  }
//  _oId = nil;
//  for (NSManagedObject *obj in moArray) {
//    _oId = [obj objectID];
//    NSMutableDictionary *ary = [NSMutableDictionary dictionary];
//    [ary setValue:[obj valueForKey:@"visited_at"] forKey:@"visited_at"];
//    [ary setValue:[obj valueForKey:@"situation"] forKey:@"situation"];
//    [ary setValue:[obj valueForKey:@"persons"] forKey:@"persons"];
//    [ary setValue:[obj valueForKey:@"fee"] forKey:@"fee"];
//    [ary setValue:[obj valueForKey:@"memo"] forKey:@"memo"];
////    [ary setValue:_oId forKey:@"oid"];
//    NSSet *master = [obj valueForKey:@"diary"];
//    if (master.count == 0) {
//      LOG(@"null");
//    } else {
//      for (NSManagedObject *shop in master) {
//        [ary setValue:[shop valueForKey:@"shop"] forKey:@"shop"];
//        [ary setValue:[shop valueForKey:@"level"] forKey:@"level"];
//      }
//    }
//    [array addObject:ary];
//  }
//  return array;
//}

//訪問履歴削除
- (BOOL)deleteDiary:(id)oid
{
  NSManagedObject *deleteObj = [self.context objectWithID:oid];
  [self.context deleteObject:deleteObj];
  if (![self save]) {
    return NO;
  }
  return YES;
}


/* 店舗情報入力 */
#pragma mark - TYShopViewController

//マスター登録数
- (BOOL)fetchMasterCount
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShopMst" inManagedObjectContext:self.context];
  [request setEntity:entity];
  [request setIncludesSubentities:NO];
  
  NSError *error = nil;
  NSUInteger cnt = [self.context countForFetchRequest:request error:&error];
  LOG(@"cnt:%lu", cnt)
  if (error) {
    LOG(@"error %@ %@", error, [error userInfo])
    return NO;
  }
  if (cnt > 0) {
    LOG()
    return YES;
  } else {
    LOG()
    return NO;
  }
}

//選択した登録済み店舗マスター
- (void)fetchShopMasterData:(NSString *)sid callback:(Callback)callback
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShopMst" inManagedObjectContext:self.context];
  [request setEntity:entity];
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"sid = %@",sid];
  [request setPredicate:pred];
  
  NSError *error = nil;
  NSArray *fetchedArray = [self.context executeFetchRequest:request error:&error];
  if (fetchedArray == nil) {
    LOG(@"fetch failure\n%@", [error localizedDescription])
  }
  if (callback) {
    callback(fetchedArray);
  }
}


/* Top 最新訪問履歴取得 */
#pragma mark - TYViewController

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
    [ary setValue:[obj objectID] forKey:@"oid"];
    [ary setValue:[obj valueForKey:@"visited_at"] forKey:@"visited"];
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


/* 訪問記録一覧リスト */
#pragma mark - TYDiaryViewController

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
    [ary setValue:[obj objectID] forKey:@"oid"];
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


/* 登録マスター参照 */
#pragma mark - TYMasterViewController

//登録マスターの取得
- (NSMutableArray *)fetchMasterData:(NSInteger)num
{
  LOG(@"num:%lu", num)
  NSMutableArray *array = [NSMutableArray array];
  NSError *error = nil;
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ShopMst"];
  NSInteger count = [self.context countForFetchRequest:request error:&error];
  request.fetchLimit = num;
  
  NSArray *fetchedArray = [_context executeFetchRequest:request error:&error];
  if (fetchedArray == nil) {
    LOG(@"fetch failure\n%@", [error localizedDescription])
    return array;
  }
  for (NSManagedObject *obj in fetchedArray) {
    NSMutableDictionary *ary = [NSMutableDictionary dictionary];
    [ary setValue:[obj valueForKey:@"shop"] forKey:@"shop"];
    [ary setValue:[obj valueForKey:@"genre"] forKey:@"genre"];
    [ary setValue:[obj valueForKey:@"area"] forKey:@"area"];
    [ary setValue:[obj valueForKey:@"sid"] forKey:@"sid"];
    [ary setValue:[NSNumber numberWithInteger:count] forKey:@"count"];
    [array addObject:ary];
  }
  return array;
}


/* 共通 */
#pragma mark - Utilty

//取消し
- (void)undo
{
  LOG()
  [self.context undo];
  NSError *error = nil;
  if (![self.context save:&error]) {
    LOG(@"error: %@", error);
  }
}

//保存
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



@end
