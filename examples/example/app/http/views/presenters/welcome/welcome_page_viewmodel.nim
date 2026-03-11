import ../../../../../../../src/basolato/view
import ../../../../../../../src/basolato/core/base


type WelcomePageViewModel* = object
  title*: string


proc new*(_: type WelcomePageViewModel): WelcomePageViewModel =
  return WelcomePageViewModel(
    title: "Basolato " & BasolatoVersion
  )
