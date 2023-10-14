// swiftlint:disable all
import Amplify
import Foundation

public struct Group: Embeddable {
  var groupID: String
  var name: String
  var userIDs: [String?]
}