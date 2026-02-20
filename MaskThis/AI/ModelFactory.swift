import FoundationModels
import Foundation
import OSLog
import BackgroundAssets
import System

@MainActor
protocol ModelFactory {
    func create() async throws -> SystemLanguageModel
}

@MainActor
class LocalModelAdapterFactory: ModelFactory {
    func create() async throws -> SystemLanguageModel {
        let url = Bundle.main.url(forResource: "mask_adapter", withExtension: "fmadapter")!
        return try! SystemLanguageModel(adapter: .init(fileURL: url))
    }
}

@MainActor
open class BGAssetsBasedFactory: ModelFactory {
    fileprivate static nonisolated let LOG = Logger(subsystem: Subsystems.AI, category: "BGAssetsFactory")
    
    private let appModel: AppModel
    private let name: String
    
    init(appModel: AppModel, name: String) {
        self.appModel = appModel
        self.name = name
    }
    
    func create() async throws -> SystemLanguageModel {
        Self.LOG.info("Creating system model instance")
        
        try SystemLanguageModel.Adapter.removeObsoleteAdapters()
        let ids = SystemLanguageModel.Adapter.compatibleAdapterIdentifiers(
             name: name
        )
        
        guard let assetPackId = ids.first else {
            throw ModelInitializationError.noCompatibleModels
        }
        
        let adapter = try SystemLanguageModel.Adapter(name: name)
        
        let statuses = try await AssetPackManager.shared.status(ofAssetPackWithID: assetPackId)
        let downloaded = check(statuses: statuses, is: .downloaded)
        let downloading = check(statuses: statuses, is: .downloading)
        if downloaded && !downloading {
            return SystemLanguageModel(adapter: adapter, guardrails: .permissiveContentTransformations)
        }

        let pack = try await AssetPackManager.shared.assetPack(withID: assetPackId)
        launchProgressUpdates(assetPackId)
        
        try await AssetPackManager.shared.ensureLocalAvailability(of: pack)
        
        return SystemLanguageModel(adapter: adapter, guardrails: .permissiveContentTransformations)
    }
    
    private nonisolated func launchProgressUpdates(_ assetPackId: String) {
        Task.detached(priority: .high) {
            let statusUpdates = AssetPackManager.shared.statusUpdates(forAssetPackWithID: assetPackId)
            for try await statusUpdate in statusUpdates {
                switch statusUpdate {
                case .began(_):
                    Self.LOG.info("Began")
                    await self.updateModelState(.downloading(fraction: 0))
                case .downloading(_, let progress):
                    Self.LOG.info("Received progress")
                    await self.updateModelState(.downloading(fraction: progress.fractionCompleted))
                case .failed(_, let error):
                    Self.LOG.info("Failed to install")
                    throw error
                case .paused(_):
                    Self.LOG.info("Paused")
                    await self.updateModelState(.paused)
                case .finished(_):
                    Self.LOG.info("Download finished")
                    return
                default:
                    Self.LOG.info("Unknown status update: \(statusUpdate.description)")
                }
            }
        }
    }
    
    private nonisolated func checkStatus(forId id: String, is status: AssetPack.Status) async throws -> Bool {
        let statuses = try await AssetPackManager.shared.status(ofAssetPackWithID: id)
        return check(statuses: statuses, is: status)
    }
    
    private nonisolated func check(statuses: AssetPack.Status, is status: AssetPack.Status) -> Bool {
        Self.LOG.info("Checking status for \(status.rawValue)")
        
        Self.LOG.info("Current status is downloaded \(statuses.contains(.downloaded))")
        Self.LOG.info("Current status is downloadAvailable \(statuses.contains(.downloadAvailable))")
        Self.LOG.info("Current status is updateAvailable \(statuses.contains(.updateAvailable))")
        Self.LOG.info("Current status is upToDate \(statuses.contains(.upToDate))")
        Self.LOG.info("Current status is outOfDate \(statuses.contains(.outOfDate))")
        Self.LOG.info("Current status is obsolete \(statuses.contains(.obsolete))")
        Self.LOG.info("Current status is downloading \(statuses.contains(.downloading))")

        return statuses.contains(status)
    }
    
    private func updateModelState(_ state: ModelState) {
        appModel.modelState = state
    }
}

@MainActor
class BGAssetsFactory: BGAssetsBasedFactory {
    init(appModel: AppModel) {
        super.init(appModel: appModel, name: "m-adapter")
    }
}

enum ModelInitializationError: LocalizedError {
    case noCompatibleModels
    
    var errorDescription: String? {
        switch self {
        case .noCompatibleModels:
            UITexts.Statuses.Errors.noCompatibleModels
        }
    }
}
