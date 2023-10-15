// swiftlint:disable all
import Amplify
import Foundation

public struct User: Model {
  public let id: String
  public var userID: String
  public var userName: String
  public var accountType: AccountType
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      userID: String,
      userName: String,
      accountType: AccountType) {
    self.init(id: id,
      userID: userID,
      userName: userName,
      accountType: accountType,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      userID: String,
      userName: String,
      accountType: AccountType,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.userID = userID
      self.userName = userName
      self.accountType = accountType
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}