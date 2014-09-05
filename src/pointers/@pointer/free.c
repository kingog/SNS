#include "mex.h"
#include "utils.h"

void mexFunction(int nOut, mxArray *pOut[], 
		 int nIn, const mxArray *pIn[])
{ 
  mxArray *address, *data;

  if (!mxIsClass(pIn[0], "pointer"))
    mexErrMsgTxt("Input must be pointer");

  address = GetPointerData(pIn[0]);
  data = GetPointerData(address);
  mxDestroyArray(data);

  SetPointerData(address, NULL);

}


