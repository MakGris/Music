//
//  Library.swift
//  MusicApp
//
//  Created by Maksim Grischenko on 24.10.2022.
//

import SwiftUI

struct Library: View {
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { geometry in
                    HStack(spacing: 20) {
                        Button {
                            print("12345")
                        } label: {
                            Image(systemName: "play.fill")
                                .tint(Color(uiColor: UIColor(
                                    displayP3Red: 253/255,
                                    green: 45/255,
                                    blue: 85/255,
                                    alpha: 1
                                )))
                                .frame(width: geometry.size.width / 2 - 10, height: 50)
                                .background {
                                    Color(uiColor: .secondarySystemBackground)
                                        .cornerRadius(10)
                                    
                                }
                        }
                        Button {
                            print("54321")
                        } label: {
                            Image(systemName: "arrow.2.circlepath")
                                .tint(Color(uiColor: UIColor(
                                    displayP3Red: 253/255,
                                    green: 45/255,
                                    blue: 85/255,
                                    alpha: 1
                                )))
                                .frame(width: geometry.size.width / 2 - 10, height: 50)
                                .background {
                                    Color(uiColor: .secondarySystemBackground)
                                        .cornerRadius(10)
                                    
                                }
                            
                        }
                    }
                }
                .padding()
                .frame(height: 50)
                
                Divider()
                    .padding(.top)
                    .padding(.leading)
                    .padding(.trailing)
                List {
                    LibraryCell()
                    Text("Second")
                    Text("Third")
                }
                .listStyle(.plain)
                
            }
                .navigationTitle("Library")
        }
    }
}

struct LibraryCell: View {
    var body: some View {
        HStack {
            Image("Image")
                .resizable()
                .frame(width: 60, height: 60)
                .cornerRadius(2)
                .listStyle(.plain)
            VStack {
                Text("TrackName")
                Text("ArtistName")
            }
        }
        
        .alignmentGuide(.listRowSeparatorLeading) { viewDemensions in
            0
        }
    }
}

struct Library_Previews: PreviewProvider {
    static var previews: some View {
        Library()
    }
}
