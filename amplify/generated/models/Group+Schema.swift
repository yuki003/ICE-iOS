// swiftlint:disable all
import Amplify
import Foundation

extension Group {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case groupName
    case description
    case thumbnailKey
    case hostUserIDs
    case belongingUserIDs
    case taskIDs
    case rewardIDs
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let group = Group.keys
    
    model.listPluralName = "Groups"
    model.syncPluralName = "Groups"
    
    model.attributes(
      .primaryKey(fields: [group.id])
    )
    
    model.fields(
      .field(group.id, is: .required, ofType: .string),
      .field(group.groupName, is: .required, ofType: .string),
      .field(group.description, is: .optional, ofType: .string),
      .field(group.thumbnailKey, is: .optional, ofType: .string),
      .field(group.hostUserIDs, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(group.belongingUserIDs, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(group.taskIDs, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(group.rewardIDs, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(group.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(group.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Group: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}