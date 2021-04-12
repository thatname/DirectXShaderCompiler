// RUN: %dxc -T lib_6_x -D TEST_NUM=0 %s | FileCheck -check-prefix=CHK0 %s
// RUN: %dxc -T lib_6_x -D TEST_NUM=1 %s | FileCheck -check-prefix=CHK1 %s
// RUN: %dxc -T lib_6_x -D TEST_NUM=2 %s | FileCheck -check-prefix=CHK2 %s
// RUN: %dxc -T lib_6_x -D TEST_NUM=3 %s | FileCheck -check-prefix=CHK3 %s
// RUN: %dxc -T lib_6_5 -D TEST_NUM=4 %s -enable-payload-qualifiers | FileCheck -input=stderr -check-prefix=CHK4 %s
// RUN: %dxc -T lib_6_6 -D TEST_NUM=4 %s | FileCheck -input=stderr -check-prefix=CHK5 %s
// RUN: %dxc -T lib_6_6 -D TEST_NUM=4 %s -enable-payload-qualifiers | FileCheck -check-prefix=CHK6 %s
// RUN: %dxc -T lib_6_6 -D TEST_NUM=5 %s -enable-payload-qualifiers | FileCheck -check-prefix=CHK7 %s

// CHK0: error: shader must include inout payload structure parameter.
// CHK1: error: ray payload parameter must be declared inout
// CHK2: error: ray payload parameter must be a user defined type with only numeric contents.
// CHK3: error: ray payload parameter must be a user defined type with only numeric contents.

// check if we get DXIL and the payload type is there 
// CHK4: Invalid target for payload access qualifiers. Only lib_6_6 and beyond are supported.
// CHK5: warning: payload access qualifieres are only supported for target lib_6_6 and beyond. You can opt-in for lib_6_6 with the -enable-payload-qualifiers flag. Qualifiers will be dropped.
// CHK6: %struct.Payload = type { i32, i32 }

// CHK7: error: type 'Payload' used as payload requires that it is annotated with the {{\[[a-z]*\]}} attribute

#if TEST_NUM <= 4
struct [raypayload] Payload {
    int a : read(closesthit) : write(caller);
    int b : write(closesthit) : read(caller);
};
#else 
struct Payload {
    int a;
    int b : read (caller) : write(closesthit);
};
#endif

// test if compilation fails if payload is not present
#if TEST_NUM == 0
[shader("miss")]
void Miss(){}
#endif

// test if compilation fails if payload is not inout
#if TEST_NUM == 1
[shader("miss")]
void Miss2( in Payload payload){}
#endif

// test if compilation fails if payload is not a user defined type
#if TEST_NUM == 2
[shader("miss")]
void Miss3(inout int payload){}
#endif

#if TEST_NUM == 3
[shader("miss")]
void Miss3(inout matrix<float, 2, 2> payload){}
#endif

// test if compilation fails because not all payload filds are qualified for lib_6_6
// test if compilation succeeds for lib_6_5 where payload access qualifiers are not required
#if TEST_NUM == 4
[shader("miss")]
void Miss4(inout Payload payload){
}
#endif

#if TEST_NUM == 5
[shader("miss")]
void Miss5(inout Payload payload){
    payload.b = 42;
}
#endif