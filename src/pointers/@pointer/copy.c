#include "mex.h"
#include "utils.h"

void mexFunction(int nOut, mxArray *pOut[], 
		 int nIn, const mxArray *pIn[])
{ 
  mxArray *address, *data;

  address = GetPointerData(pIn[0]);

  pOut[0] = MakeStructCopyAndCreatePointer(GetPointerData(address));
}


