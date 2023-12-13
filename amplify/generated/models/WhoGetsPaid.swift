// swiftlint:disable all
import Amplify
import Foundation

public enum WhoGetsPaid: String, EnumPersistable, CaseIterable {
  case onlyOne = "ONLY_ONE"
  case everybody = "EVERYBODY"
  case limited = "LIMITED"
}
