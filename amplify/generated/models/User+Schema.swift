// swiftlint:disable all
import Amplify
import Foundation

extension User {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case userID
    case userName
    case accountType
    case hostGroupIDs
    case belongingGroupIDs
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let user = User.keys
    
    model.listPluralName = "Users"
    model.syncPluralName = "Users"
    
    model.attributes(
      .primaryKey(fields: [user.id])
    )
    
    model.fields(
      .field(user.id, is: .required, ofType: .string),
      .field(user.userID, is: .required, ofType: .string),
      .field(user.userName, is: .required, ofType: .string),
      .field(user.accountType, is: .required, ofType: .enum(type: AccountType.self)),
      .field(user.hostGroupIDs, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(user.belongingGroupIDs, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(user.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(user.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension User: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}