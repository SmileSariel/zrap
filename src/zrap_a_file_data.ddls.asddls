@EndUserText.label: 'ZRAP_A_FILE_DATA'
define root abstract entity ZRAP_A_FILE_DATA 
{
  @UI.hidden:true
  mimeType      : abap.char(128);
  @UI.hidden:true
  fileName      : abap.char(128); 
  @Semantics.largeObject : { 
    mimeType: 'mimeType', 
    fileName: 'fileName', 
    acceptableMimeTypes: [ 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ],
    cacheControl.maxAge: #MEDIUM,
    contentDispositionPreference: #INLINE // #ATTACHMENT - download as file #INLINE - open in new window
  }  
  @EndUserText.label: 'Please select file'  
  fileContent   : abap.rawstring(0);
}
