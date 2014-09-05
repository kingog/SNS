#include "mex.h"
#include "utils.h"

/*
   Nikolai Yu. Zolotykh (c) 2004, 2005
   Svetlana Gagarinova  (c) 2005
*/

void mexFunction(int nOut, mxArray *pOut[], 
		 int nIn, const mxArray *pIn[])
{  
  mxArray *address, *data,*s;
  char *field_name;
  int len, field_number;
  pOut[0] = pIn[0];
  address = GetPointerData(pOut[0]);
  data = GetPointerData(address);

  if (!data)
  { 
    data = mxCreateStructMatrix(1, 1, 0, NULL);
    mexMakeArrayPersistent(data);
    SetPointerData(address, data);
  }

  field_name = AllocAndGetString(pIn[1]);

  field_number = mxGetFieldNumber(data, field_name);
  if (field_number != -1)
  {
     s = mxGetFieldByNumber(data, 0, field_number); 
     mxDestroyArray(s); 
  }
  else
  //if(field_number==-1)     
  {
    mxAddField(data, field_name);
    field_number = mxGetFieldNumber(data, field_name);
  }
  mxSetFieldByNumber(data, 0, field_number, mxDuplicateArray(pIn[2]));
  mxFree(field_name); 
}



