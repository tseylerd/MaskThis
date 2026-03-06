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
    private static nonisolated let EXTENSION = "fmadapter"
    
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
        Self.LOG.info("Removed obsolete adapters")

        guard let assetPackId = Util.compatibleAdapterIdentifier(name) else {
            Self.LOG.info("Compatible adapter id is nil")
            throw ModelInitializationError.noCompatibleModels
        }
        
        Self.LOG.info("Received compatible id: \(assetPackId)")
        Self.LOG.info("Resolving URL")
        let url = try await resolveURL(assetPackId)
        
        Self.LOG.info("Constructing adapter")
        let adapter = try SystemLanguageModel.Adapter(fileURL: url)
        
        Self.LOG.info("Constructing model")
        return SystemLanguageModel(adapter: adapter, guardrails: .permissiveContentTransformations)
    }
    
    private func resolveURL(_ assetPackId: String) async throws -> URL {
        do {
            return try await resolveBGAssetsAdapter(assetPackId)
        } catch {
            Self.LOG.error("Failed to resolve URL using AssetPackManager api: \(error.localizedDescription)")
            return try resolveLocalAdapter(assetPackId)
        }
    }
    
    private func resolveBGAssetsAdapter(_ assetPackId: String) async throws -> URL {
        Self.LOG.info("Trying to get adapter via background assets")
        let assetPack = try await AssetPackManager.shared.assetPack(withID: assetPackId)
        Self.LOG.info("Got asset pack with id: \(assetPack.id)")
        launchProgressUpdates(assetPackId)

        Self.LOG.info("Ensuring local availability")
        try await AssetPackManager.shared.ensureLocalAvailability(of: assetPack)
        
        Self.LOG.info("Getting url")
        let adapterUrl = try await Task.detached(priority: .high) {
            try AssetPackManager.shared.url(for: .init("\(assetPackId).\(Self.EXTENSION)"))
        }.value
        return adapterUrl
    }
    
    private func resolveLocalAdapter(_ assetPackId: String) throws -> URL {
        Self.LOG.info("Trying to get adapter via bundled")
        let url = Bundle.main.url(forResource: assetPackId, withExtension: Self.EXTENSION)
        guard let url else {
            throw ModelInitializationError.noCompatibleModels
        }
        Self.LOG.info("Have adapter in bundle")
       
        return url
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

    private func updateModelState(_ state: ModelState) {
        appModel.modelState = state
    }
}

@MainActor
class BGAssetsFactory: BGAssetsBasedFactory {
    init(appModel: AppModel) {
        super.init(appModel: appModel, name: Constants.adapterName)
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
