@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZRAP_EXCEL'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZRAP_I_EXCEL
  as select from zrap_excel
{
  key who_uuid as WhoUUID,
  customer as Customer,
  article as Article, 
  messagetype as MessageType,
  case messagetype when 'E' then 1
                   when 'W' then 2
                   when 'S' then 3
                   else 0
  end as MessageCode,
  messagetext as MessageText,
  @Semantics.user.createdBy: true
  createdby as Createdby,
  @Semantics.systemDateTime.createdAt: true
  createdat as Createdat,
  @Semantics.user.localInstanceLastChangedBy: true
  lastchangedby as Lastchangedby,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  lastchangedat as Lastchangedat,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  locallastchangedat as Locallastchangedat
}
