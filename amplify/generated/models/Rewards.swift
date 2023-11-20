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
  public var periodicType: PeriodicType?
  public var whoGetsPaid: WhoGetsPaid
  public var getUserID: [String?]?
  public var cost: Int
  public var groupId: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      createUserID: String,
      rewardName: String,
      description: String? = nil,
      thumbnailKey: String? = nil,
      frequencyType: FrequencyType,
      periodicType: PeriodicType? = nil,
      whoGetsPaid: WhoGetsPaid,
      getUserID: [String?]? = nil,
      cost: Int,
      groupId: String? = nil) {
    self.init(id: id,
      createUserID: createUserID,
      rewardName: rewardName,
      description: description,
      thumbnailKey: thumbnailKey,
      frequencyType: frequencyType,
      periodicType: periodicType,
      whoGetsPaid: whoGetsPaid,
      getUserID: getUserID,
      cost: cost,
      groupId: groupId,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      createUserID: String,
      rewardName: String,
      description: String? = nil,
      thumbnailKey: String? = nil,
      frequencyType: FrequencyType,
      periodicType: PeriodicType? = nil,
      whoGetsPaid: WhoGetsPaid,
      getUserID: [String?]? = nil,
      cost: Int,
      groupId: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.createUserID = createUserID
      self.rewardName = rewardName
      self.description = description
      self.thumbnailKey = thumbnailKey
      self.frequencyType = frequencyType
      self.periodicType = periodicType
      self.whoGetsPaid = whoGetsPaid
      self.getUserID = getUserID
      self.cost = cost
      self.groupId = groupId
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}