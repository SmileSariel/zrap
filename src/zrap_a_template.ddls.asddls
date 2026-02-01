@EndUserText.label: 'ZRAP_A_FILECONTENT'
define root abstract entity ZRAP_A_TEMPLATE
{
  fileName    : abap.char(128);
  mimeType    : abap.char(128);
  fileContent : abap.rawstring(0);
}
