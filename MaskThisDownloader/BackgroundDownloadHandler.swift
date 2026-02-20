import BackgroundAssets
import ExtensionFoundation
import StoreKit
import FoundationModels

@main
struct DownloaderExtension: StoreDownloaderExtension {
    func shouldDownload(_ assetPack: AssetPack) -> Bool {
        return SystemLanguageModel.Adapter.isCompatible(assetPack)
    }
}
