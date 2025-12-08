//
//  BackgroundDownloadHandler.swift
//  Mask This Model Adapter
//
//  Created by Dmitrii Tseiler on 12.02.26.
//

import BackgroundAssets
import ExtensionFoundation
import StoreKit

@main
struct DownloaderExtension: StoreDownloaderExtension {
    func shouldDownload(_ assetPack: AssetPack) -> Bool {
        return true
    }
}
