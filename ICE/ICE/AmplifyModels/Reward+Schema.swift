// swiftlint:disable all
import Amplify
import Foundation

extension Reward {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case rewardID
    case name
    case description
    case groupID
    case cost
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let reward = Reward.keys
    
    model.listPluralName = "Rewards"
    model.syncPluralName = "Rewards"
    
    model.fields(
      .field(reward.rewardID, is: .required, ofType: .string),
      .field(reward.name, is: .required, ofType: .string),
      .field(reward.description, is: .optional, ofType: .string),
      .field(reward.groupID, is: .required, ofType: .string),
      .field(reward.cost, is: .required, ofType: .int)
    )
    }
}