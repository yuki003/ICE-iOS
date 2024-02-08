// swiftlint:disable all
import Amplify
import Foundation

public struct TaskReports: Model {
  public let id: String
  public var taskID: String
  public var reportUserID: String
  public var pictureKey: String?
  public var picture1: String?
  public var picture2: String?
  public var picture3: String?
  public var reports: [String?]?
  public var rejectedComment: [String?]?
  public var approvedComment: String?
  public var status: ReportStatus?
  public var reportVersion: Int?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      taskID: String,
      reportUserID: String,
      pictureKey: String? = nil,
      picture1: String? = nil,
      picture2: String? = nil,
      picture3: String? = nil,
      reports: [String?]? = nil,
      rejectedComment: [String?]? = nil,
      approvedComment: String? = nil,
      status: ReportStatus? = nil,
      reportVersion: Int? = nil) {
    self.init(id: id,
      taskID: taskID,
      reportUserID: reportUserID,
      pictureKey: pictureKey,
      picture1: picture1,
      picture2: picture2,
      picture3: picture3,
      reports: reports,
      rejectedComment: rejectedComment,
      approvedComment: approvedComment,
      status: status,
      reportVersion: reportVersion,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      taskID: String,
      reportUserID: String,
      pictureKey: String? = nil,
      picture1: String? = nil,
      picture2: String? = nil,
      picture3: String? = nil,
      reports: [String?]? = nil,
      rejectedComment: [String?]? = nil,
      approvedComment: String? = nil,
      status: ReportStatus? = nil,
      reportVersion: Int? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.taskID = taskID
      self.reportUserID = reportUserID
      self.pictureKey = pictureKey
      self.picture1 = picture1
      self.picture2 = picture2
      self.picture3 = picture3
      self.reports = reports
      self.rejectedComment = rejectedComment
      self.approvedComment = approvedComment
      self.status = status
      self.reportVersion = reportVersion
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}