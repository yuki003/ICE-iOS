// swiftlint:disable all
import Amplify
import Foundation

public struct User: Embeddable {
  var userID: String
  var name: String
  var groupIDs: [String?]?
  var accountType: AccountType
}