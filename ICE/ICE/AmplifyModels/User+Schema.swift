// swiftlint:disable all
import Amplify
import Foundation

extension User {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case userID
    case name
    case groupIDs
    case accountType
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let user = User.keys
    
    model.listPluralName = "Users"
    model.syncPluralName = "Users"
    
    model.fields(
      .field(user.userID, is: .required, ofType: .string),
      .field(user.name, is: .required, ofType: .string),
      .field(user.groupIDs, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(user.accountType, is: .required, ofType: .enum(type: AccountType.self))
    )
    }
}