type SettingTemplateModel* = object
  errors*:seq[string]
  image*:string
  name*:string
  bio*:string
  email*:string

proc new*(_:type SettingTemplateModel, errors:seq[string], image:string, name:string, bio:string, email:string):SettingTemplateModel =
  return SettingTemplateModel(errors: errors, image: image, name: name, bio: bio, email: email)


proc new*(_:type SettingTemplateModel, image:string, name:string, bio:string, email:string):SettingTemplateModel =
  return SettingTemplateModel(image: image, name: name, bio: bio, email: email)
