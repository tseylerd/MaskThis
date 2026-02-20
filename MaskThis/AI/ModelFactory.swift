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
        
        let statusUpdates = AssetPackManager.shared.statusUpdates(forAssetPackWithID: assetPackId)
        dloop: for try await statusUpdate in statusUpdates {
            switch statusUpdate {
            case .began(_):
                self.updateModelState(.downloading(fraction: 0))
            case .downloading(_, let progress):
                self.updateModelState(.downloading(fraction: progress.fractionCompleted))
            case .failed(_, let error):
                 throw error
            case .paused(_):
                self.updateModelState(.paused)
            case .finished(_):
                Self.LOG.info("Download finished: \(statusUpdate)")
                break dloop
            default:
                Self.LOG.info("Unknown status update: \(statusUpdate)")
            }
        }
        
        return SystemLanguageModel(adapter: adapter, guardrails: .permissiveContentTransformations)
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
