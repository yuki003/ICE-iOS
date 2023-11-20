// swiftlint:disable all
import Amplify
import Foundation

public enum FrequencyType: String, EnumPersistable {
  case onlyOnce = "ONLY_ONCE"
  case periodic = "PERIODIC"
}