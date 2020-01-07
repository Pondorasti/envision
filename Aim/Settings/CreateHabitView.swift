//
//  CreateHabitView.swift
//  Aim
//
//  Created by Alexandru Turcanu on 05/01/2020.
//  Copyright © 2020 Alexandru Turcanu. All rights reserved.
//

import SwiftUI

struct CreateHabitView: View {

    var navBarTitle = "Create Habit"

    @State var habitName: String = ""
    @State var habitType: Int = 0

    private var habitTypes = ["Good", "Bad"]

    @State private var colorPickerWidth = CGFloat()

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Habit Name").font(.headline)) {
                    TextField("Name", text: $habitName)
                }

                Section(header: Text("Habit Type").font(.headline)) {
                    Picker("Habit Type", selection: $habitType) {
                        ForEach(0 ..< habitTypes.count) {
                            Text("\(self.habitTypes[$0])")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }

                Section(header: Text("Color of Bubble").font(.headline)) {
                    GeometryReader { geometry in
                        ColorPickerView(size: CGSize(width: geometry.size.width, height: 64))
                            .frame(width: geometry.size.width, height: 64, alignment: .center)
                    }
                    .scaledToFill()
                    .frame(height: 64)
                }
            }
            .listStyle(GroupedListStyle())
            .environment(\.horizontalSizeClass, .regular)
            .navigationBarTitle(navBarTitle)
        }
    }
}

struct CreateHabitView_Previews: PreviewProvider {
    static var previews: some View {
        CreateHabitView()
    }
}



