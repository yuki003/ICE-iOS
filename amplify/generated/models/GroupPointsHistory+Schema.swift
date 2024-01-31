// swiftlint:disable all
import Amplify
import Foundation

extension GroupPointsHistory {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case userID
    case completedTaskID
    case receivedRewardID
    case total
    case pending
    case spent
    case amount
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let groupPointsHistory = GroupPointsHistory.keys
    
    model.listPluralName = "GroupPointsHistories"
    model.syncPluralName = "GroupPointsHistories"
    
    model.attributes(
      .primaryKey(fields: [groupPointsHistory.id])
    )
    
    model.fields(
      .field(groupPointsHistory.id, is: .required, ofType: .string),
      .field(groupPointsHistory.userID, is: .required, ofType: .string),
      .field(groupPointsHistory.completedTaskID, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(groupPointsHistory.receivedRewardID, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(groupPointsHistory.total, is: .required, ofType: .int),
      .field(groupPointsHistory.pending, is: .required, ofType: .int),
      .field(groupPointsHistory.spent, is: .required, ofType: .int),
      .field(groupPointsHistory.amount, is: .required, ofType: .int),
      .field(groupPointsHistory.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(groupPointsHistory.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension GroupPointsHistory: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}