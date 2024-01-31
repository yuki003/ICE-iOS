// swiftlint:disable all
import Amplify
import Foundation

extension Tasks {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case createUserID
    case receivingUserIDs
    case completedUserIDs
    case taskName
    case description
    case iconName
    case frequencyType
    case condition
    case point
    case groupID
    case startDate
    case endDate
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let tasks = Tasks.keys
    
    model.listPluralName = "Tasks"
    model.syncPluralName = "Tasks"
    
    model.attributes(
      .primaryKey(fields: [tasks.id])
    )
    
    model.fields(
      .field(tasks.id, is: .required, ofType: .string),
      .field(tasks.createUserID, is: .required, ofType: .string),
      .field(tasks.receivingUserIDs, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(tasks.completedUserIDs, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(tasks.taskName, is: .required, ofType: .string),
      .field(tasks.description, is: .optional, ofType: .string),
      .field(tasks.iconName, is: .required, ofType: .string),
      .field(tasks.frequencyType, is: .required, ofType: .enum(type: FrequencyType.self)),
      .field(tasks.condition, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(tasks.point, is: .required, ofType: .int),
      .field(tasks.groupID, is: .required, ofType: .string),
      .field(tasks.startDate, is: .optional, ofType: .dateTime),
      .field(tasks.endDate, is: .optional, ofType: .dateTime),
      .field(tasks.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(tasks.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Tasks: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}