import UIKit

extension CALayer {
    func applyDynamicBorderColor(color: UIColor, for traitCollection: UITraitCollection) {
        borderColor = color.resolvedColor(with: traitCollection).cgColor
    }
}
