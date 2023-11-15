// swiftlint:disable all
import Amplify
import Foundation

public struct Group: Model {
  public let id: String
  public var groupName: String
  public var description: String?
  public var thumbnailKey: String?
  public var hostUserIDs: [String?]?
  public var belongingUserIDs: [String?]?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      groupName: String,
      description: String? = nil,
      thumbnailKey: String? = nil,
      hostUserIDs: [String?]? = nil,
      belongingUserIDs: [String?]? = nil) {
    self.init(id: id,
      groupName: groupName,
      description: description,
      thumbnailKey: thumbnailKey,
      hostUserIDs: hostUserIDs,
      belongingUserIDs: belongingUserIDs,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      groupName: String,
      description: String? = nil,
      thumbnailKey: String? = nil,
      hostUserIDs: [String?]? = nil,
      belongingUserIDs: [String?]? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.groupName = groupName
      self.description = description
      self.thumbnailKey = thumbnailKey
      self.hostUserIDs = hostUserIDs
      self.belongingUserIDs = belongingUserIDs
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}