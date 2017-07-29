import UIKit
import Marshroute
import Paparazzo

final class ExampleRouterImpl: BaseRouter, ExampleRouter {
    
    private let mediaPickerAssemblyFactory = Paparazzo.MarshrouteAssemblyFactory(
        theme: PaparazzoUITheme.appSpecificTheme()
    )
    
    // MARK: - ExampleRouter
    
    func showMediaPicker(
        items: [MediaPickerItem],
        selectedItem: MediaPickerItem?,
        maxItemsCount: Int?,
        cropCanvasSize: CGSize,
        configuration: (MediaPickerModule) -> ()
    ) {
        pushViewControllerDerivedFrom { routerSeed in
            
            let assembly = mediaPickerAssemblyFactory.mediaPickerAssembly()
            
            return assembly.module(
                items: items,
                selectedItem: selectedItem,
                maxItemsCount: maxItemsCount,
                cropEnabled: true,
                selfieEnabled: false,
                cropCanvasSize: cropCanvasSize,
                routerSeed: routerSeed,
                configuration: configuration
            )
        }
    }
    
    func showPhotoLibrary(
        selectedItems: [PhotoLibraryItem],
        maxSelectedItemsCount: Int?,
        configuration: (PhotoLibraryModule) -> ()
    ) {
        presentModalNavigationControllerWithRootViewControllerDerivedFrom { routerSeed in
            
            let assembly = mediaPickerAssemblyFactory.photoLibraryAssembly()
            
            return assembly.module(
                selectedItems: selectedItems,
                maxSelectedItemsCount: maxSelectedItemsCount,
                routerSeed: routerSeed,
                configuration: configuration
            )
        }
    }
}
