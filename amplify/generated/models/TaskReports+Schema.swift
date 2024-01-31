// swiftlint:disable all
import Amplify
import Foundation

extension TaskReports {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case taskID
    case reportUserID
    case picture1
    case picture2
    case picture3
    case reports
    case rejectedComment
    case approvedComment
    case status
    case reportVersion
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let taskReports = TaskReports.keys
    
    model.listPluralName = "TaskReports"
    model.syncPluralName = "TaskReports"
    
    model.attributes(
      .primaryKey(fields: [taskReports.id])
    )
    
    model.fields(
      .field(taskReports.id, is: .required, ofType: .string),
      .field(taskReports.taskID, is: .required, ofType: .string),
      .field(taskReports.reportUserID, is: .required, ofType: .string),
      .field(taskReports.picture1, is: .optional, ofType: .string),
      .field(taskReports.picture2, is: .optional, ofType: .string),
      .field(taskReports.picture3, is: .optional, ofType: .string),
      .field(taskReports.reports, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(taskReports.rejectedComment, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(taskReports.approvedComment, is: .optional, ofType: .string),
      .field(taskReports.status, is: .optional, ofType: .enum(type: ReportStatus.self)),
      .field(taskReports.reportVersion, is: .optional, ofType: .int),
      .field(taskReports.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(taskReports.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension TaskReports: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}