//
//  TaskApprovalViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/02/05.
//


import SwiftUI
import Amplify
import Combine

final class TaskApprovalViewModel: ViewModelBase {
    // MARK: Properties
    @Published var comment: String = ""
    @Published var selectedImage: String = ""
    @Published var image: UIImage = UIImage()
    @Published var images: [UIImage] = []
    let keys = TaskReports.keys
    
    // MARK: Flags
    @Published var approve: Bool = false
    @Published var reject: Bool = false
    @Published var approveComplete: Bool = false
    @Published var rejectComplete: Bool = false
    @Published var showImage: Bool = false
    
    // MARK: Instances
    @Published var task: Tasks
    @Published var reportsWithUsers: [ReportWithUserInfo] = []
    @Published var selectedReport: TaskReports?
    
    // MARK: Validations
    
    // MARK: initializer
    init(task: Tasks)
    {
        self.task = task
    }
    @MainActor
    func loadData() async throws {
        asyncOperation({ [self] in
            let reportPredicate = keys.taskID.eq(task.id)
            let reportList = try await apiHandler.list(TaskReports.self, where: reportPredicate, keyName: "\(task.id)-reports")
            if !reportList.isEmpty {
                var userIDs: [String] = []
                userIDs = reportList.map{ $0.reportUserID }
                let userPredicate = self.apiService.orPredicateGroupByID(ids: userIDs, model: User.keys.userID)
                if let predicate = userPredicate {
                    let users = try await apiHandler.list(User.self, where: predicate, keyName: "\(task.id)-reports-users")
                    for report in reportList {
                        reportsWithUsers.append(ReportWithUserInfo(report: report, user: users.first(where: { $0.userID == report.reportUserID })))
                    }
                }
            }
        }, apiErrorHandler: { apiError in
            self.setErrorMessage(apiError)
        }, errorHandler: { error in
            self.setErrorMessage(error)
        })
    }
    @MainActor
    func reportApprove() async {
        asyncOperation({ [self] in
            if let selectedReport = selectedReport  {
                var pointHistoryModel: GroupPointsHistory
                let pointHistoryPredicate = GroupPointsHistory.keys.userID.eq(selectedReport.reportUserID)
                var pointHistory = try await apiHandler.list(GroupPointsHistory.self, where: pointHistoryPredicate, keyName: "\(task.id)-\(selectedReport.reportUserID)-point")
                if pointHistory.isEmpty {
                    pointHistoryModel = GroupPointsHistory(userID: selectedReport.reportUserID, completedTaskID: [task.id], total: task.point, pending: 0, spent: 0, amount: task.point)
                    try await apiHandler.create(pointHistoryModel, keyName: "\(task.id)-\(selectedReport.reportUserID)-point")
                } else {
                    pointHistory[0].total = pointHistory[0].total + task.point
                    pointHistory[0].amount = pointHistory[0].amount + task.point
                    if let completedTask = pointHistory[0].completedTaskID {
                        pointHistory[0].completedTaskID?.append(task.id)
                    } else {
                        pointHistory[0].completedTaskID = [task.id]
                    }
                    try await apiHandler.update(pointHistory[0], keyName: "\(task.id)-\(selectedReport.reportUserID)-point")
                }
                
                var selectedReport = selectedReport
                if comment.isNotEmpty {
                    selectedReport.approvedComment = comment
                }
                selectedReport.status = .approved
                selectedReport.reportVersion = selectedReport.reportVersion! + 1
                try await self.apiHandler.update(selectedReport, keyName: "\(task.id)-reports")
            }
            approveComplete = true
        }, apiErrorHandler: { apiError in
            self.setErrorMessage(apiError)
        }, errorHandler: { error in
            self.setErrorMessage(error)
        })
    }
    @MainActor
    func reportReject() async {
        asyncOperation({ [self] in
            if let selectedReport = selectedReport  {
                var selectedReport = selectedReport
                if comment.isNotEmpty {
                    if selectedReport.rejectedComment != nil {
                        selectedReport.rejectedComment?.append(comment)
                    } else {
                        selectedReport.rejectedComment = [comment]
                    }
                }
                selectedReport.status = .rejected
                selectedReport.reportVersion = selectedReport.reportVersion! + 1
                try await self.apiHandler.update(selectedReport, keyName: "\(task.id)-reports")
            }
            rejectComplete = true
        }, apiErrorHandler: { apiError in
            self.setErrorMessage(apiError)
        }, errorHandler: { error in
            self.setErrorMessage(error)
        })
    }
    func fetchImages(_ urlList: String?...) -> [UIImage] {
        var images: [UIImage?] = []
        for url in urlList {
            if let url = url {
                images.append(UIImage(url: url))
            }
        }
        return images.compactMap{ $0 }
    }
}

struct ReportWithUserInfo {
    var report: TaskReports
    var user: User?
}
