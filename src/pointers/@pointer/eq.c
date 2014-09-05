#include "mex.h"
#include "utils.h"

void mexFunction(int nOut, mxArray *pOut[], 
		 int nIn, const mxArray *pIn[])
{ 
  mxArray *dataA, *dataB;
  mxLogical value;

  if (mxIsClass(pIn[0], "pointer") && mxIsClass(pIn[1], "pointer"))
  {
    dataA = GetPointerData(pIn[0]);
    if (!GetPointerData(dataA))
      dataA = NULL;
    dataB = GetPointerData(pIn[1]);
    if (!GetPointerData(dataB))
      dataB = NULL;
  }
  else if (mxIsClass(pIn[0], "pointer") && mxIsDouble(pIn[1]) 
    && mxGetM(pIn[1])*mxGetN(pIn[1]) == 1 && !mxGetScalar(pIn[1]))
  {
    dataA = GetPointerData(GetPointerData(pIn[0]));
    dataB = NULL;
  }
  else if (mxIsClass(pIn[1], "pointer") && mxIsDouble(pIn[0]) 
    && mxGetM(pIn[0])*mxGetN(pIn[0]) == 1 && !mxGetScalar(pIn[0]))
  {
    dataA = NULL;
    dataB = GetPointerData(GetPointerData(pIn[1]));
  }
  else
    mexErrMsgTxt("Both inputs must be pointers or one of them is pointer and other is scalar 0 (= NULL)");

  value = dataA == dataB;

  pOut[0] = mxCreateLogicalScalar(value);
}


