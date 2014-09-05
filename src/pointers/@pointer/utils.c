#include "mex.h"
#include "utils.h"

mxArray* RegisterObject(mxArray *strct, const char *obj_name)
{
  mxArray *In[2], *Out[1];

  In[0] = strct;
  In[1] = mxCreateString(obj_name);

  mexCallMATLAB(1, Out, 2, In, "class");

//  In[0] = mxCreateString("struct");
//  mexCallMATLAB(0, NULL, 1, In, "inferiorto");  // inferiorto struct
  
return Out[0];
//return strct;
}

mxArray* CreateObject(int m, int n, int nfields, const char *field_names[], const char *obj_name)
{
  mxArray *strct;

  strct = mxCreateStructMatrix(m, n, nfields, field_names);

  //mxSetClassName(strct, obj_name);

  //return strct;

  return RegisterObject(strct, obj_name);
}

char* AllocAndGetString(const mxArray *A)
{
  char *str;
  int len;

  len = mxGetN(A) + 1;
  str = mxCalloc(len, sizeof(char));
  if (mxGetString(A, str, len) != 0) 
    mexWarnMsgTxt("Not enough space. String is truncated.");

  return str;
}

mxArray* MakeStructCopyAndCreatePointer(const mxArray *data)
{
  const char *field_names[] = {"data"};
  mxArray *A, *address, *copy_data;

  A = CreateObject(1, 1, 1, field_names, "pointer");
  address = mxCreateStructMatrix(1, 1, 1, field_names);
  mexMakeArrayPersistent(address);
  SetPointerData(A, address);

  if (data)
  {
    copy_data = mxDuplicateArray(data);
    mexMakeArrayPersistent(copy_data);
  }            
  else
    copy_data = NULL;


  SetPointerData(address, copy_data);

  return A;
}


void SetPointerData(mxArray *A, const mxArray *data)
{
  mxArray *address;

  address = mxCreateNumericMatrix(sizeof(data), 1, mxUINT8_CLASS, mxREAL);
  memcpy((void *)mxGetPr(address), (void *)(&data), sizeof(data));

  mxSetFieldByNumber(A, 0, 0, address);
}

mxArray* GetPointerData(const mxArray *A)
{
  mxArray *address, *data;

  address = mxGetFieldByNumber(A, 0, 0);
  memcpy((void *)(&data), (void *)(mxGetPr(address)), sizeof(data));

  return data;
}


