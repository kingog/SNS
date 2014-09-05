#include "mex.h"
#include "utils.h"

void mexFunction(int nOut, mxArray *pOut[], 
		 int nIn, const mxArray *pIn[])
{ 
  mxArray *address, *data;

  address = GetPointerData(pIn[0]);
  data = GetPointerData(address);

  if (data)
    pOut[0] = mxDuplicateArray(data);
  else
    pOut[0] = mxCreateStructMatrix(1, 1, 0, NULL);
}


