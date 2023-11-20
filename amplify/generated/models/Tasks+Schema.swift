// swiftlint:disable all
import Amplify
import Foundation

extension Tasks {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case createUserID
    case taskName
    case description
    case frequencyType
    case periodicType
    case condition
    case point
    case groupID
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
      .field(tasks.taskName, is: .required, ofType: .string),
      .field(tasks.description, is: .optional, ofType: .string),
      .field(tasks.frequencyType, is: .required, ofType: .enum(type: FrequencyType.self)),
      .field(tasks.periodicType, is: .optional, ofType: .enum(type: PeriodicType.self)),
      .field(tasks.condition, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(tasks.point, is: .required, ofType: .int),
      .field(tasks.groupID, is: .optional, ofType: .string),
      .field(tasks.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(tasks.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Tasks: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}