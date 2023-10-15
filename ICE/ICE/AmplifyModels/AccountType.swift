// swiftlint:disable all
import Amplify
import Foundation

public enum AccountType: String, EnumPersistable {
  case guest = "GUEST"
  case host = "HOST"
}