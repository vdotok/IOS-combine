//
//  ContentView.swift
//  watch WatchKit Extension
//
//  Created by usama farooq on 28/02/2022.
//  Copyright © 2022 VDOTOK. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var viewModel = ViewModel()
    var body: some View {
        VStack {
            Text("Hello VDO TOK ")
                .padding()
        }.background(Color.yellow)
    
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
