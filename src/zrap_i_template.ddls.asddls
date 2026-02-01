@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZRAP_TEMPLATE'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZRAP_I_TEMPLATE
  as select from ZRAP_TEMPLATE
{
  key progid as Progid,
  comments as Comments,
  file_name as FileName,
  mime_type as MimeType,
  file_content as FileContent,
  @Semantics.user.createdBy: true
  local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at as LocalCreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt
}
