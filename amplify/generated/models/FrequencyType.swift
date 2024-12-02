// swiftlint:disable all
import Amplify
import Foundation

public enum FrequencyType: String, EnumPersistable, CaseIterable {
  case onlyOnce = "ONLY_ONCE"
  case everyDay = "EVERY_DAY"
  case weekDay = "WEEK_DAY"
  case holiday = "HOLIDAY"
  case oncePerWeek = "ONCE_PER_WEEK"
  case oncePerMonth = "ONCE_PER_MONTH"
  case oncePerYear = "ONCE_PER_YEAR"
}
