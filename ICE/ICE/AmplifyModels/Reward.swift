// swiftlint:disable all
import Amplify
import Foundation

public struct Reward: Embeddable {
  var rewardID: String
  var name: String
  var description: String?
  var groupID: String
  var cost: Int
}