#include "mex.h"
#include "utils.h"

void mexFunction(int nOut, mxArray *pOut[], 
		 int nIn, const mxArray *pIn[])
{ 
  if (nIn > 1)
    mexErrMsgTxt("Too many inputs");

  if (nOut > 1)
    mexErrMsgTxt("Too many output arguments");
  
  if (nIn == 0)
    pOut[0] = MakeStructCopyAndCreatePointer(NULL);
  else
  {
    if (mxIsStruct(pIn[0]))
      if (mxIsClass(pIn[0], "pointer"))
        pOut[0] = mxDuplicateArray(pIn[0]);
      else
        pOut[0] = MakeStructCopyAndCreatePointer(pIn[0]);
    else
      mexErrMsgTxt("Input must be struct or pointer");
  }
}
