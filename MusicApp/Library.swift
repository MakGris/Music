//
//  Library.swift
//  MusicApp
//
//  Created by Maksim Grischenko on 24.10.2022.
//

import SwiftUI
import URLImage

struct Library: View {
    @State var tracks = UserDefaults.standard.savedTracks()
    @State private var showingAlert = false
    @State private var track: SearchViewModel.Cell!
    
    var tabBarDelegate: MAinTabBarControllerDelegate?
    
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { geometry in
                    HStack(spacing: 20) {
                        Button {
                            self.track = self.tracks[0]
                            self.tabBarDelegate?.maximizeTrackDetailController(viewModel: self.track)
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
                            self.tracks = UserDefaults.standard.savedTracks()
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
                List() {
                    ForEach(tracks) { track in
                        LibraryCell(cell: track)
                            .gesture(LongPressGesture()
                                .onEnded({ _ in
                                    self.track = track
                                    showingAlert = true
                                })
                                    .simultaneously(with: TapGesture()
                                        .onEnded({ _ in
                                            let keyWindow = UIApplication.shared.connectedScenes.filter ({
                                                $0.activationState == .foregroundActive
                                            }).map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.filter({$0.isKeyWindow}).first
                                            let tabBarVC = keyWindow?.rootViewController as? MainTabBarController
                                            tabBarVC?.trackDetailView.delegate = self
                                            self.track = track
                                            tabBarDelegate?.maximizeTrackDetailController(viewModel: self.track)
                                        })))
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
                
            }
            .actionSheet(isPresented: $showingAlert, content: {
                ActionSheet(
                    title: Text("Are you sure you want to delete this track?"),
                    buttons: [.destructive(Text("Delete"), action: {
                        print("Deleting: \(self.track.trackName)")
                        self.delete(track: track)
                    }), .cancel()]
                )
            })
            .navigationTitle("Library")
        }
    }
    
    func delete(at offsets: IndexSet) {
        tracks.remove(atOffsets: offsets)
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: UserDefaults.favoriteTrackKey)
        }
    }
    func delete(track: SearchViewModel.Cell) {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return }
        tracks.remove(at: myIndex)
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: UserDefaults.favoriteTrackKey)
        }
    }
}

struct LibraryCell: View {
    var cell: SearchViewModel.Cell
    var body: some View {
        HStack {
            URLImage(URL(string: cell.iconUrlString ?? "")!) { image in
                image.resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(2)
                    .listStyle(.plain)
            }
            VStack(alignment: .leading) {
                Text("\(cell.trackName)")
                Text("\(cell.artistName)")
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

extension Library: TrackMovingDelegate {
    func moveBackForPreviousTrack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        var nextTrack: SearchViewModel.Cell
        if myIndex - 1 == -1 {
            nextTrack = tracks[tracks.count - 1]
        } else {
            nextTrack = tracks[myIndex - 1]
        }
        self.track = nextTrack
        return nextTrack
    }
    
    func moveForwardForNextTrack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        var nextTrack: SearchViewModel.Cell
        if myIndex + 1 == tracks.count {
            nextTrack = tracks[0]
        } else {
            nextTrack = tracks[myIndex + 1]
        }
        self.track = nextTrack
        return nextTrack
    }
    
    
}
