/* Code generated by cmd/cgo; DO NOT EDIT. */

/* package command-line-arguments */


#line 1 "cgo-builtin-export-prolog"

#include <stddef.h> /* for ptrdiff_t below */

#ifndef GO_CGO_EXPORT_PROLOGUE_H
#define GO_CGO_EXPORT_PROLOGUE_H

#ifndef GO_CGO_GOSTRING_TYPEDEF
typedef struct { const char *p; ptrdiff_t n; } _GoString_;
#endif

#endif

/* Start of preamble from import "C" comments.  */


#line 3 "application.go"

#include "callback.h"

#line 1 "cgo-generated-wrapper"





/* End of preamble from import "C" comments.  */


/* Start of boilerplate cgo prologue.  */
#line 1 "cgo-gcc-export-header-prolog"

#ifndef GO_CGO_PROLOGUE_H
#define GO_CGO_PROLOGUE_H

typedef signed char GoInt8;
typedef unsigned char GoUint8;
typedef short GoInt16;
typedef unsigned short GoUint16;
typedef int GoInt32;
typedef unsigned int GoUint32;
typedef long long GoInt64;
typedef unsigned long long GoUint64;
typedef GoInt64 GoInt;
typedef GoUint64 GoUint;
typedef __SIZE_TYPE__ GoUintptr;
typedef float GoFloat32;
typedef double GoFloat64;
typedef float _Complex GoComplex64;
typedef double _Complex GoComplex128;

/*
  static assertion to make sure the file is being used on architecture
  at least with matching size of GoInt.
*/
typedef char _check_for_64_bit_pointer_matching_GoInt[sizeof(void*)==64/8 ? 1:-1];

#ifndef GO_CGO_GOSTRING_TYPEDEF
typedef _GoString_ GoString;
#endif
typedef void *GoMap;
typedef void *GoChan;
typedef struct { void *t; void *v; } GoInterface;
typedef struct { void *data; GoInt len; GoInt cap; } GoSlice;

#endif

/* End of boilerplate cgo prologue.  */

#ifdef __cplusplus
extern "C" {
#endif


/* Return type for initApp */
struct initApp_return {
	GoInt r0;
	char* r1;
};

extern struct initApp_return initApp(GoString p0, GoString p1, GoString p2, GoString p3, SystemActionCallBack p4, BlockChainDataSyncNotifier p5);

/* Return type for startService */
struct startService_return {
	GoInt r0;
	char* r1;
};

extern struct startService_return startService(GoString p0, GoString p1, GoString p2);

extern void stopService();

extern char* MyChannelWithDetails(GoString p0);

/* Return type for BuyPacket */
struct BuyPacket_return {
	char* r0;
	char* r1;
};

extern struct BuyPacket_return BuyPacket(GoString p0, GoString p1, GoString p2, GoFloat64 p3);

extern GoFloat64 QueryApproved(GoString p0);

extern GoInt64 QueryMicroPayPrice();

extern char* PoolDetails(GoString p0);

extern char* PoolInfosInMarket();

extern void AsyncLoadMarketData();

extern char* OpenMicroPayChannel(GoString p0, GoString p1, GoString p2, GoString p3);

extern void CloseMicroPayChannel();

extern char* RunVpnService(GoString p0);

extern void StopVpnService();

extern GoUint8 WalletVerify(GoString p0, GoString p1);

/* Return type for TransferEth */
struct TransferEth_return {
	char* r0;
	char* r1;
};

extern struct TransferEth_return TransferEth(GoString p0, GoString p1, GoFloat64 p2);

/* Return type for TransferLinToken */
struct TransferLinToken_return {
	char* r0;
	char* r1;
};

extern struct TransferLinToken_return TransferLinToken(GoString p0, GoString p1, GoFloat64 p2);

extern char* SyncWalletInfo();

/* Return type for NewWallet */
struct NewWallet_return {
	GoUint8 r0;
	char* r1;
};

extern struct NewWallet_return NewWallet(GoString p0);

#ifdef __cplusplus
}
#endif
