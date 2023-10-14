// swiftlint:disable all
import Amplify
import Foundation

extension Group {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case groupID
    case name
    case userIDs
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let group = Group.keys
    
    model.listPluralName = "Groups"
    model.syncPluralName = "Groups"
    
    model.fields(
      .field(group.groupID, is: .required, ofType: .string),
      .field(group.name, is: .required, ofType: .string),
      .field(group.userIDs, is: .required, ofType: .embeddedCollection(of: String.self))
    )
    }
}