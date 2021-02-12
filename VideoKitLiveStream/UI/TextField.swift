//
//  TextField.swift
//  VideoKitLiveStream
//
//  Created by Dennis Stücken on 2/10/21.
//
import UIKit

public class TextField: UITextField, UITextFieldDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    fileprivate func setup() {
        self.keyboardType = .URL
        self.returnKeyType = .done
        self.autocapitalizationType = .none
        self.autocorrectionType = .default
        self.spellCheckingType = .no
        self.clearButtonMode = .never
        self.layer.cornerRadius = self.frame.height * 0.25
    }
}
