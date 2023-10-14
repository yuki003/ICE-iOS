// swiftlint:disable all
import Amplify
import Foundation

public struct Task: Embeddable {
  var taskID: String
  var name: String
  var description: String?
  var groupID: String
  var point: Int
}