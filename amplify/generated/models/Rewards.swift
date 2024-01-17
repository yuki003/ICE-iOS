// swiftlint:disable all
import Amplify
import Foundation

public struct Rewards: Model {
  public let id: String
  public var createUserID: String
  public var rewardName: String
  public var description: String?
  public var thumbnailKey: String?
  public var frequencyType: FrequencyType
  public var whoGetsPaid: WhoGetsPaid
  public var getUserID: [String?]?
  public var cost: Int
  public var groupID: String
  public var startDate: Temporal.DateTime?
  public var endDate: Temporal.DateTime?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      createUserID: String,
      rewardName: String,
      description: String? = nil,
      thumbnailKey: String? = nil,
      frequencyType: FrequencyType,
      whoGetsPaid: WhoGetsPaid,
      getUserID: [String?]? = nil,
      cost: Int,
      groupID: String,
      startDate: Temporal.DateTime? = nil,
      endDate: Temporal.DateTime? = nil) {
    self.init(id: id,
      createUserID: createUserID,
      rewardName: rewardName,
      description: description,
      thumbnailKey: thumbnailKey,
      frequencyType: frequencyType,
      whoGetsPaid: whoGetsPaid,
      getUserID: getUserID,
      cost: cost,
      groupID: groupID,
      startDate: startDate,
      endDate: endDate,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      createUserID: String,
      rewardName: String,
      description: String? = nil,
      thumbnailKey: String? = nil,
      frequencyType: FrequencyType,
      whoGetsPaid: WhoGetsPaid,
      getUserID: [String?]? = nil,
      cost: Int,
      groupID: String,
      startDate: Temporal.DateTime? = nil,
      endDate: Temporal.DateTime? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.createUserID = createUserID
      self.rewardName = rewardName
      self.description = description
      self.thumbnailKey = thumbnailKey
      self.frequencyType = frequencyType
      self.whoGetsPaid = whoGetsPaid
      self.getUserID = getUserID
      self.cost = cost
      self.groupID = groupID
      self.startDate = startDate
      self.endDate = endDate
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}