// swiftlint:disable all
import Amplify
import Foundation

extension Rewards {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case createUserID
    case rewardName
    case description
    case thumbnailKey
    case frequencyType
    case whoGetsPaid
    case getUserID
    case cost
    case groupID
    case startDate
    case endDate
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let rewards = Rewards.keys
    
    model.listPluralName = "Rewards"
    model.syncPluralName = "Rewards"
    
    model.attributes(
      .primaryKey(fields: [rewards.id])
    )
    
    model.fields(
      .field(rewards.id, is: .required, ofType: .string),
      .field(rewards.createUserID, is: .required, ofType: .string),
      .field(rewards.rewardName, is: .required, ofType: .string),
      .field(rewards.description, is: .optional, ofType: .string),
      .field(rewards.thumbnailKey, is: .optional, ofType: .string),
      .field(rewards.frequencyType, is: .required, ofType: .enum(type: FrequencyType.self)),
      .field(rewards.whoGetsPaid, is: .required, ofType: .enum(type: WhoGetsPaid.self)),
      .field(rewards.getUserID, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(rewards.cost, is: .required, ofType: .int),
      .field(rewards.groupID, is: .required, ofType: .string),
      .field(rewards.startDate, is: .optional, ofType: .dateTime),
      .field(rewards.endDate, is: .optional, ofType: .dateTime),
      .field(rewards.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(rewards.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Rewards: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}