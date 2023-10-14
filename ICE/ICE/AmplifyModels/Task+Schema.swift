// swiftlint:disable all
import Amplify
import Foundation

extension Task {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case taskID
    case name
    case description
    case groupID
    case point
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let task = Task.keys
    
    model.listPluralName = "Tasks"
    model.syncPluralName = "Tasks"
    
    model.fields(
      .field(task.taskID, is: .required, ofType: .string),
      .field(task.name, is: .required, ofType: .string),
      .field(task.description, is: .optional, ofType: .string),
      .field(task.groupID, is: .required, ofType: .string),
      .field(task.point, is: .required, ofType: .int)
    )
    }
}