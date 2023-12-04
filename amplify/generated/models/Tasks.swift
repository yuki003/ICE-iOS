// swiftlint:disable all
import Amplify
import Foundation

public struct Tasks: Model {
  public let id: String
  public var createUserID: String
  public var taskName: String
  public var description: String?
  public var iconName: String?
  public var frequencyType: FrequencyType
  public var periodicType: PeriodicType?
  public var condition: [String?]?
  public var point: Int
  public var groupID: String?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      createUserID: String,
      taskName: String,
      description: String? = nil,
      iconName: String? = nil,
      frequencyType: FrequencyType,
      periodicType: PeriodicType? = nil,
      condition: [String?]? = nil,
      point: Int,
      groupID: String? = nil) {
    self.init(id: id,
      createUserID: createUserID,
      taskName: taskName,
      description: description,
      iconName: iconName,
      frequencyType: frequencyType,
      periodicType: periodicType,
      condition: condition,
      point: point,
      groupID: groupID,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      createUserID: String,
      taskName: String,
      description: String? = nil,
      iconName: String? = nil,
      frequencyType: FrequencyType,
      periodicType: PeriodicType? = nil,
      condition: [String?]? = nil,
      point: Int,
      groupID: String? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.createUserID = createUserID
      self.taskName = taskName
      self.description = description
      self.iconName = iconName
      self.frequencyType = frequencyType
      self.periodicType = periodicType
      self.condition = condition
      self.point = point
      self.groupID = groupID
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}