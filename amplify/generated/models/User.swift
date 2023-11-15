// swiftlint:disable all
import Amplify
import Foundation

public struct User: Model {
  public let id: String
  public var userID: String
  public var userName: String
  public var thumbnailKey: String?
  public var accountType: AccountType
  public var hostGroupIDs: [String?]?
  public var belongingGroupIDs: [String?]?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      userID: String,
      userName: String,
      thumbnailKey: String? = nil,
      accountType: AccountType,
      hostGroupIDs: [String?]? = nil,
      belongingGroupIDs: [String?]? = nil) {
    self.init(id: id,
      userID: userID,
      userName: userName,
      thumbnailKey: thumbnailKey,
      accountType: accountType,
      hostGroupIDs: hostGroupIDs,
      belongingGroupIDs: belongingGroupIDs,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      userID: String,
      userName: String,
      thumbnailKey: String? = nil,
      accountType: AccountType,
      hostGroupIDs: [String?]? = nil,
      belongingGroupIDs: [String?]? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.userID = userID
      self.userName = userName
      self.thumbnailKey = thumbnailKey
      self.accountType = accountType
      self.hostGroupIDs = hostGroupIDs
      self.belongingGroupIDs = belongingGroupIDs
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}