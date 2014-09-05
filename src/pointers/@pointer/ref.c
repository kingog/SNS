#include "mex.h"
#include "utils.h"

void mexFunction(int nOut, mxArray *pOut[], 
		 int nIn, const mxArray *pIn[])
{ 

  mxArray *address, *data;
  char *field_name;
  int field_number;

  // assert(nOut == 2)
  // assert(nIn == 2)

  address = GetPointerData(pIn[0]);
  data = GetPointerData(address);

  if (!data)
  {
     //mexErrMsgTxt("Pointer is NULL");
     pOut[0] = mxCreateScalarDouble(0);
     pOut[1] = mxCreateScalarDouble(0);
  }
  else
  {
    field_name = AllocAndGetString(pIn[1]);

    field_number = mxGetFieldNumber(data, field_name);
    if (field_number == -1)
    {
      //mexErrMsgTxt("Reference to non-existent field");
      pOut[0] = mxCreateScalarDouble(-1);
      pOut[1] = mxCreateScalarDouble(-1);
    }
    else
    {
      pOut[0] = mxGetFieldByNumber(data, 0, field_number);
      pOut[1] = mxCreateScalarDouble(1);
    }
    mxFree(field_name);
  }
}




