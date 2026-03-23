import ../../../../../../../src/basolato/view


type SamplePageViewModel* = object


proc new*(_: type SamplePageViewModel): SamplePageViewModel =
  return SamplePageViewModel()
