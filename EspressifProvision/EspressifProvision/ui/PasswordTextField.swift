//
//  PasswordTextField.swift
//  EspressifProvision
//
//  Created by Vikas Chandra on 21/01/20.
//  Copyright © 2020 Espressif. All rights reserved.
//

import UIKit

class PasswordTextField: UITextField {
    var tapGesture: UITapGestureRecognizer!
    let passwordImageRightView = UIImageView(frame: CGRect(x: 0, y: 0, width: 22.0, height: 16.0))
    let passwordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 22.0, height: 16.0))

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        passwordButton.setImage(UIImage(named: "show_password"), for: .normal)
        rightView = passwordButton
        rightViewMode = .always
        passwordButton.addTarget(self, action: #selector(showPasswordTapped), for: .touchUpInside)
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x = rect.origin.x - 16
//        tapGesture = UITapGestureRecognizer(target: passwordImageRightView, action: #selector(showPasswordTapped))
        return rect
    }

    @objc func showPasswordTapped() {
        togglePasswordVisibility()
    }

    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
         // Drawing code
     }
     */
}
