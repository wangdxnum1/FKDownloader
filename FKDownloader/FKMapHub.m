//
//  FKMapHub.m
//  FKDownloaderDemo
//
//  Created by Norld on 2018/12/6.
//  Copyright © 2018 Norld. All rights reserved.
//

#import "FKMapHub.h"
#import "FKTask.h"
#import "FKDefine.h"

@interface FKMapHub ()

@property (nonatomic, strong) NSLock *lock;

// TODO: 使用 NSSet 储存 task, 忽略顺序, 使用新的集合保存顺序
@property (nonatomic, copy  ) NSMutableArray<FKTask *> *tasks;
@property (nonatomic, copy  ) NSMutableDictionary<NSString *, FKTask *> *taskMap;
@property (nonatomic, copy  ) NSMutableDictionary<NSString *, NSMutableSet<FKTask *> *> *tagMap;

@end

@implementation FKMapHub
#pragma mark - Task
- (void)addTask:(FKTask *)task withTag:(nullable NSString *)tag {
    if ([self.tasks containsObject:task] == NO) {
        [self.tasks addObject:task];
        self.taskMap[task.identifier] = task;
    }
    if (tag.length > 0) {
        if (self.tagMap[tag] == nil) {
            self.tagMap[tag] = [NSMutableSet set];
        }
        [self.tagMap[tag] addObject:task];
    }
}

- (void)removeTask:(FKTask *)task {
    if ([self.tasks containsObject:task]) {
        [self.tasks removeObject:task];
        [self.taskMap removeObjectForKey:task.identifier];
    }
    for (NSString *tag in task.tags) {
        if ([self.tagMap.allKeys containsObject:tag]) {
            [self.tagMap[tag] removeObject:task];
        }
    }
}


#pragma mark - Tag
- (void)addTag:(NSString *)tag to:(FKTask *)task {
    if ([self.tasks containsObject:task] == NO) { return; }
    if (self.tagMap[tag] == nil) {
        self.tagMap[tag] = [NSMutableSet set];
    }
    [self.tagMap[tag] addObject:task];
}

- (void)removeTag:(NSString *)tag from:(FKTask *)task {
    [self.tagMap[tag] removeObject:task];
}


#pragma mark - Operation
- (NSArray<FKTask *> *)allTask {
    return [self.tasks copy];
}

- (FKTask *)taskWithIdentifier:(NSString *)identifier {
    return self.taskMap[identifier];
}

- (NSArray<FKTask *> *)taskForTag:(NSString *)tag {
    if (self.tagMap[tag] == nil) { return @[]; }
    return self.tagMap[tag].allObjects;
}

- (BOOL)containsTask:(FKTask *)task {
    return [self.tasks containsObject:task];
}

- (NSInteger)countOfTasks {
    return self.tasks.count;
}

- (void)clear {
    [self.tasks removeAllObjects];
    [self.taskMap removeAllObjects];
    [self.tagMap removeAllObjects];
}


#pragma mark - Getter/Setter
- (NSLock *)lock {
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}

- (NSMutableArray<FKTask *> *)tasks {
    if (!_tasks) {
        _tasks = [NSMutableArray array];
    }
    return _tasks;
}

- (NSMutableDictionary<NSString *,FKTask *> *)taskMap {
    if (!_taskMap) {
        _taskMap = [NSMutableDictionary dictionary];
    }
    return _taskMap;
}

- (NSMutableDictionary<NSString *,NSMutableSet<FKTask *> *> *)tagMap {
    if (!_tagMap) {
        _tagMap = [NSMutableDictionary dictionary];
    }
    return _tagMap;
}

@end
