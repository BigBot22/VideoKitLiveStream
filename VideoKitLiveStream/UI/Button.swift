//
//  Button.swift
//  VideoKitLiveStream
//
//  Created by Dennis Stücken on 2/10/21.
//
import UIKit

let kDefaultButtonHeight: CGFloat = 30

class Button: UIButton {
    @IBInspectable public var cornerRadius: CGFloat = kDefaultButtonHeight / 2
    
    override var isHighlighted: Bool {
        didSet {
            guard oldValue != self.isHighlighted else { return }
            
            UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                self.alpha = self.isHighlighted ? 0.8 : 1
            }, completion: nil)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }

    func setSecondaryButton() {
        titleLabel?.textColor = .white
        setTitleColor(UIColor.white, for: .normal)
        backgroundColor = .black
    }
    
    func setPrimaryButton() {
        backgroundColor = .blue
        setTitleColor(.white, for: .normal)
        titleLabel?.textColor = .white
    }

    func setupButton() {
        setPrimaryButton()
        
        titleLabel?.font     = UIFont(name: "Avenir-Medium", size: 18)
        titleLabel?.center.x = center.x
        titleLabel?.textAlignment = .center

        layer.cornerRadius = cornerRadius
        layer.borderWidth    = 0
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width + 30, height: size.height)
    }
}
