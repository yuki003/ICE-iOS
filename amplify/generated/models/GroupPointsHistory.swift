// swiftlint:disable all
import Amplify
import Foundation

public struct GroupPointsHistory: Model {
  public let id: String
  public var userID: String
  public var completedTaskID: [String?]?
  public var receivedRewardID: [String?]?
  public var total: Int
  public var pending: Int
  public var spent: Int
  public var amount: Int
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      userID: String,
      completedTaskID: [String?]? = nil,
      receivedRewardID: [String?]? = nil,
      total: Int,
      pending: Int,
      spent: Int,
      amount: Int) {
    self.init(id: id,
      userID: userID,
      completedTaskID: completedTaskID,
      receivedRewardID: receivedRewardID,
      total: total,
      pending: pending,
      spent: spent,
      amount: amount,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      userID: String,
      completedTaskID: [String?]? = nil,
      receivedRewardID: [String?]? = nil,
      total: Int,
      pending: Int,
      spent: Int,
      amount: Int,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.userID = userID
      self.completedTaskID = completedTaskID
      self.receivedRewardID = receivedRewardID
      self.total = total
      self.pending = pending
      self.spent = spent
      self.amount = amount
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}