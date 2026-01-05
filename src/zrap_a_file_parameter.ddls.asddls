@EndUserText.label: 'ZRAP_A_FILE_PARAMETER'
define abstract entity ZRAP_A_FILE_PARAMETER 
{
  mimeType      : abap.char(128);
  fileName      : abap.char(128);
  fileContent   : abap.rawstring(0);
  fileExtension : abap.char(128);
}
