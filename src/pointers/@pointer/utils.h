#include "mex.h"

mxArray* RegisterObject(mxArray *strct, const char *obj_name);

mxArray* CreateObject(int m, int n, int nfields, const char *field_names[], const char *obj_name);

char* AllocAndGetString(const mxArray *A);

mxArray* MakeStructCopyAndCreatePointer(const mxArray *data);

mxArray* MakeStructCopyAndCreateObject(int m, int n, int nfields, const char *field_names[], const char *obj_name);

void SetPointerData(mxArray *A, const mxArray *data);

mxArray* GetPointerData(const mxArray *A);

