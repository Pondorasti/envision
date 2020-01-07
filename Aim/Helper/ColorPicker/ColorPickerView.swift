//
//  ColorPickerView.swift
//  Aim
//
//  Created by Alexandru Turcanu on 07/01/2020.
//  Copyright © 2020 Alexandru Turcanu. All rights reserved.
//

import SwiftUI

struct ColorPickerView: UIViewRepresentable {
    var size: CGSize

    func makeUIView(context: UIViewRepresentableContext<ColorPickerView>) -> PickerView {
        let picker = PickerView(
            colorEntries:
            [UIColor.red, UIColor.blue, UIColor.purple, UIColor.orange, UIColor.green,
             UIColor.red, UIColor.blue, UIColor.purple, UIColor.orange, UIColor.green],
            size: self.size
        )

        return picker
    }

    func updateUIView(_ uiView: PickerView, context: UIViewRepresentableContext<ColorPickerView>) {

    }
}
