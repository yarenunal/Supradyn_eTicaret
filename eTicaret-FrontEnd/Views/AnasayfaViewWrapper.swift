//
//  AnasayfaViewWrapper.swift
//  eTicaret-FrontEnd
//
//  Created by Yaren on 17.07.2025.
//

import SwiftUI

struct AnasayfaViewWrapper: View {
    @StateObject var viewModel = ProductViewModel()
    @State var sepet: Set<Int> = []

    var body: some View {
        AnasayfaView()
    }
}
