//
//  PostNewItem.swift
//  StudentMarket
//
//  Created by Luke Wolfram on 4/20/25.
//

//Before this is truly complete, like add the photo picker and all that first, but before you can truly add a post to a profile you need to make the profile page that shows all the posts. Likely going to have to create a struct for the posts and add it to firestore.

import SwiftUI
import PhotosUI

struct PostNewItem: View {
    
    // We need to figure out what the width and height are of the poxy as soon as the screen appears or else the photo height will change relative to the roundedRectangle height
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var uiImages: [UIImage] = []
    @State private var askingPrice: String = ""
    @State private var isEditPhotos: Bool = false
    @State private var proxyWidthForSheet: CGFloat = 0
    @State private var proxyHeightForSheet: CGFloat = 0
    @FocusState var isFocused: Bool
    
    
    @State private var currentImageIndex: Int = 0

    
    var body: some View {
        
        addPhotoZStack
        
        VStack {
            
            Image(systemName: "camera.badge.ellipsis.fill")
                .onTapGesture {
                    guard uiImages.count == 0 else {
                        isEditPhotos = true
                        return
                    }
                }
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            VStack {
            TextField("Asking price", text: $askingPrice)
                .keyboardType(.decimalPad)
                .focused($isFocused)
                }
            .padding()
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isFocused = false
                    }
                }

                }
            
            
            Button("Post") {
                
            }
            Button("Cancel") {
                
            }
        }
        .sheet(isPresented: $isEditPhotos, content: {
            EidtPhotosSheet(
                uiImages: $uiImages,
                proxyWidthForSheet: $proxyWidthForSheet,
                proxyHeightForsheet: $proxyHeightForSheet, 
                selectedItems: $selectedItems
            )
        })
        
            Spacer()
            
            
    }
        
}

#Preview {
    PostNewItem()
}


extension PostNewItem {
    
    private var addPhotoZStack: some View {
        ZStack {
            if uiImages.count != 0 {
                GeometryReader { proxy in
                    let width = proxy.size.width
                    let height = proxy.size.height
                    
                    ZStack(alignment: .bottom) {
                        
                        TabView(selection: $currentImageIndex) {
                            ForEach(uiImages.indices, id: \.self) { index in
                                Image(uiImage: uiImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: width, height: height)
                                    .clipShape(.rect(cornerRadius: 25))
                                    .tag(index)
                                    .ignoresSafeArea()
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        
                        HStack(spacing: 8) {
                            ForEach(uiImages.indices, id: \.self) { index in
                                Circle()
                                    .frame(width: 10, height: 10)
                                    .foregroundStyle(index == currentImageIndex ? .white : .white.opacity(0.3))
                            }
                        }
                        .padding(.bottom, 20)

                        
                        
//                        ScrollView(.horizontal) {
//                            LazyHStack(spacing: 0) {
//                                ForEach(uiImages, id: \.self) { image in
//                                    Image(uiImage: image)
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: width, height: height)
//                                        .clipShape(.rect(cornerRadius: 25))
//                                    
//                                }
//                            }
//                            .scrollTargetLayout()
//                            
//                        }
//                        .scrollIndicators(.never)
//                        .scrollTargetBehavior(.paging)
//                        .ignoresSafeArea()
//                        .onAppear {
//                            proxyWidthForSheet = width / 1.3
//                            proxyHeightForSheet = height / 1.3
//                        }
//                        
//                        ForEach(0...uiImages.count, id: \.self) { _ in
//                            Circle()
//                                    .frame(width: 15, height: 15)
//                                    .padding(.vertical, 20)
//                                    .foregroundStyle(.white)
//                            }
                    }
                    .ignoresSafeArea()
                }

            } else if uiImages.count == 0 {
                
                
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 5, matching: .images
                ) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25.0)
                                .foregroundStyle(.white)
                                .shadow(radius: 10)
                                .frame(maxWidth: .infinity)
                                .frame(height: 429)
                            Image(systemName: "plus")
                                .font(.largeTitle)
                            
                        }
                    }
                
            }
            }
        .ignoresSafeArea()
        .frame(height: 350)
        .onChange(of: selectedItems) { _, _ in
            Task {
                uiImages = []
                
                for item in selectedItems {
                    do {
                        if let data = try await item.loadTransferable(type: Data.self) {
                            if let image = UIImage(data: data) {
                                uiImages.append(image)
                            }
                        }
                    } catch {
                        print(item)
                        print("Error!")
                        print(error)
                    }
                }
                print("uiImages.count: ", uiImages.count)
                print("selectedItems.count ", selectedItems.count)

                            }
        }

    }
}


struct EidtPhotosSheet: View {
    
    @Binding var uiImages: [UIImage]
    @Binding var proxyWidthForSheet: CGFloat
    @Binding var proxyHeightForsheet: CGFloat
    @State private var isRemovePressed: Bool = false
    @Binding var selectedItems: [PhotosPickerItem]
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Spacer()
                Button(isRemovePressed ? "Cancel" : "Remove") {
                    withAnimation {
                        isRemovePressed.toggle()
                    }
                }
                PhotosPicker("Add", selection: $selectedItems, maxSelectionCount: 5)
            }
            .font(.headline)
            .padding(35)
            Spacer()
            
            ScrollView(.horizontal) {
                HStack(spacing: 15) {
                    ForEach(uiImages, id: \.self) { image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxyWidthForSheet, height: proxyHeightForsheet)
                                .clipShape(.rect(cornerRadius: 25))
                                .padding()
                            
                            Button {
                                    if let index = uiImages.firstIndex(of: image) {
                                        withAnimation {
                                            uiImages.remove(at: index)
                                            selectedItems.remove(at: index)
                                        }
                                    }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.red)
                                    .opacity(isRemovePressed ? 1 : 0)
                            }
                            .allowsHitTesting(isRemovePressed ? true : false)
                        }
                    }
                }
                
                .frame(maxHeight: .infinity)
            }
            .frame(height: proxyHeightForsheet)
            .scrollIndicators(.never)
            
            Spacer()
        }
    }
}
