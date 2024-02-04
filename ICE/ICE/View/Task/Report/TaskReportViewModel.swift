//
//  TaskReportViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/01/31.
//

import SwiftUI
import Amplify
import Combine

final class TaskReportViewModel: ViewModelBase {
    // MARK: Properties
    @Published var report: String = ""
    @Published var image: UIImage = UIImage()
    @Published var images: [UIImage] = []
    let keys = TaskReports.keys
    
    // MARK: Flags
    @Published var reportComplete: Bool = false
    @Published var isShowConfirmation: Bool = false
    @Published var isShowCameraView: Bool = false
    @Published var isShowPhotoLibrary: Bool = false
    
    // MARK: Instances
    @Published var task: Tasks
    @Published var taskReports: TaskReports?
    
    // MARK: Validations
    
    // MARK: initializer
    init(task: Tasks)
    {
        self.task = task
    }
    
    @MainActor
    func loadData() async throws {
        asyncOperation({ [self] in
            if apiHandler.isRunFetch(userDefaultKey: "\(task.id)-report") || reload {
                let reportPredicate = keys.taskID.eq(task.id) && keys.reportUserID.eq(userID)
                let reportList = try await apiHandler.list(TaskReports.self, where: reportPredicate, keyName: "\(task.id)-report")
                if !reportList.isEmpty {
                    taskReports = reportList[0]
                    let reportIndex = reportList[0].reportVersion! - 1
                    report = reportList[0].reports![reportIndex] ?? ""
                    images = fetchImages(taskReports?.picture1,taskReports?.picture2,taskReports?.picture3)
                }
            } else {
                let reportList = try self.apiHandler.decodeUserDefault(modelType: [TaskReports].self, key: "\(task.id)-report") ?? []
                if !reportList.isEmpty {
                    taskReports = reportList[0]
                    let reportIndex = reportList[0].reportVersion! - 1
                    report = reportList[0].reports![reportIndex] ?? ""
                    images = fetchImages(taskReports?.picture1,taskReports?.picture2,taskReports?.picture3)
                }
            }
        }, apiErrorHandler: { apiError in
            self.setErrorMessage(apiError)
        }, errorHandler: { error in
            self.setErrorMessage(error)
        })
    }
    @MainActor
    func repotTask() async throws {
        asyncOperation({ [self] in
            showAlert = false
            var model = TaskReports(taskID: task.id, reportUserID: userID, status: ReportStatus.pending, reportVersion: (taskReports?.reportVersion ?? 0) + 1)
            
            if images.count > 0, images[0].isNotEmpty() {
                let image  = images[0]
                let key = task.id + model.id + "pic1"
                let url = try await self.storage.uploadData(image, key: key)
                model.picture1 = url
            }
            if images.count > 1, images[1].isNotEmpty() {
                let image  = images[1]
                let key = task.id + model.id + "pic2"
                let url = try await self.storage.uploadData(image, key: key)
                model.picture2 = url
            }
            
            if images.count > 2, images[2].isNotEmpty() {
                let image  = images[2]
                let key = task.id + model.id + "pic3"
                let url = try await self.storage.uploadData(image, key: key)
                model.picture3 = url
            }
            
            if let taskReports = taskReports {
                model.reports = taskReports.reports
                model.reports?.append(report)
                try await apiHandler.update(model, keyName: "\(task.id)-report")
            } else {
                model.reports = [report]
                try await apiHandler.create(model, keyName: "\(task.id)-report")
            }
            reportComplete = true
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
