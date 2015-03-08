//
//  iTermTests.m
//  iTerm
//
//  Created by George Nachman on 10/16/13.
//
//

#import "iTermTests.h"
#import <objc/runtime.h>
#import "iTermApplicationDelegate.h"

@implementation iTermTest
@end

#define DECLARE_TEST(t) \
@interface t : iTermTest \
@end

DECLARE_TEST(VT100GridTest)
DECLARE_TEST(VT100ScreenTest)
DECLARE_TEST(IntervalTreeTest)
DECLARE_TEST(AppleScriptTest)
DECLARE_TEST(NSStringCategoryTest)
DECLARE_TEST(PTYTextViewTest)
DECLARE_TEST(PTYSessionTest)
DECLARE_TEST(iTermPasteHelperTest)
DECLARE_TEST(SemanticHistoryTest)
DECLARE_TEST(VT100XtermParserTest);
DECLARE_TEST(VT100CSIParserTest);
DECLARE_TEST(VT100DCSParserTest);

static void RunTestsInObject(iTermTest *test) {
    NSLog(@"-- Begin tests in %@ --", [test class]);
    unsigned int methodCount;
    Method *methods = class_copyMethodList([test class], &methodCount);
    for (int i = 0; i < methodCount; i++) {
        SEL name = method_getName(methods[i]);
        NSString *stringName = NSStringFromSelector(name);
        if ([stringName hasPrefix:@"test"]) {
            if ([test respondsToSelector:@selector(setup)]) {
                [test setup];
            }
            NSLog(@"Running %@", stringName);
            [test performSelector:name];
            if ([test respondsToSelector:@selector(teardown)]) {
                [test teardown];
            }
            NSLog(@"Success!");
        }
    }
    free(methods);
    NSLog(@"-- Finished tests in %@ --", [test class]);
}

NSArray *AllTestClasses() {
    return @[ [VT100GridTest class],
              [VT100ScreenTest class],
              [IntervalTreeTest class],
              [NSStringCategoryTest class],
              [AppleScriptTest class],
              [PTYTextViewTest class],
              [PTYSessionTest class],
              [iTermPasteHelperTest class],
              [SemanticHistoryTest class],
              [VT100XtermParserTest class],
              [VT100CSIParserTest class],
              [VT100DCSParserTest class]];
}

NSArray *TestClassesToRun(NSArray *include, NSArray *exclude) {
    NSArray *allTestClasses = AllTestClasses();
    assert(!(include != nil && exclude != nil));

    NSMutableArray *testClassesToRun = [NSMutableArray array];
    if (include == nil && exclude == nil) {
        NSLog(@"Running all tests");
        [testClassesToRun addObjectsFromArray:allTestClasses];
    } else if (include) {
        NSLog(@"Running only these tests: %@", include);
        [testClassesToRun addObjectsFromArray:include];
    } else {
        NSLog(@"Running all tests except: %@", exclude);
        for (Class cls in allTestClasses) {
            if (![exclude containsObject:cls]) {
                [testClassesToRun addObject:cls];
            }
        }
    }
    return testClassesToRun;
}

int main(int argc, const char * argv[]) {
    [[NSApplication sharedApplication] setDelegate:[[iTermApplicationDelegate alloc] init]];

    // Up to one of |include| or |exclude| may be non-nil. Set it to an array of test Class objects.
    // If include is set, exactly the listed tests will be run. If exclude is set, all but the
    // listed tests will run.

    NSArray *include = @[ [PTYTextViewTest class] ];
    NSArray *exclude = nil;

    NSArray *testClassesToRun = TestClassesToRun(include, exclude);
    NSLog(@"Running tests: %@", testClassesToRun);
    for (Class cls in testClassesToRun) {
        RunTestsInObject([[cls new] autorelease]);
    }

    NSLog(@"All tests passed");
    return 0;
}

