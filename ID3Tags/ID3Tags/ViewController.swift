//
//  ViewController.swift
//  ID3Test
//
//  Created by Manasa M P on 20/04/23.
//


import UIKit
import AVKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController, AVPlayerItemMetadataOutputPushDelegate, AVPlayerItemMetadataCollectorPushDelegate {
    let player = AVPlayer()
    var playerItem: AVPlayerItem!
    let asset = AVAsset(url: URL(string: "https://db2.indexcom.com/bucket/ram/00/05/05.m3u8")!)
    
    /*
     for SEI headers
     let asset = AVAsset(url: URL(string: "https://live.glance-cdn.net/recordings/sei-samples/sample1/out1/output.m3u8")!)
     */
    
    
   /*
    for ID3 headers
    let asset = AVAsset(url: URL(string: "https://db2.indexcom.com/bucket/ram/00/05/05.m3u8")!)
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readID3Headers()
    }
    
    func readID3Headers() {
        prepareToPlay()
        player.play()
    }
    
    
    func prepareToPlay() {
        playerItem = AVPlayerItem(asset: asset)
        playerItem.addObserver(self, forKeyPath: "timedMetadata", options: [], context: nil)
        player.replaceCurrentItem(with: playerItem)
        
        let metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil)
        metadataOutput.setDelegate(self, queue: DispatchQueue.main)
        playerItem.add(metadataOutput)
        
        printTimeStamp()
    }
    
    func printTimeStamp() {
        print("▼⎺▼⎺▼⎺▼⎺▼⎺▼⎺▼⎺▼")
        print("PROGRAM-DATE-TIME: ")
        print(playerItem.currentDate() ?? "No timeStamp")
        print("▲_▲_▲_▲_▲_▲_▲_▲\n\n")
    }
    
    override func observeValue(forKeyPath: String?, of: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if forKeyPath != "timedMetadata" { return }
        
        printTimeStamp()
        
        let data: AVPlayerItem = of as! AVPlayerItem
        
        guard let timedMetadata = data.timedMetadata else { return }
        
        for item in timedMetadata {
            switch item.commonKey {
                
            case .commonKeyAlbumName?:
                print("AlbumName: \(item.value!)")
            case .commonKeyArtist?:
                print("Artist: \(item.value!)")
            case .commonKeyArtwork?:
                print("Artwork: \(item.value!)")
            case .commonKeyAuthor?:
                print("Author: \(item.value!)")
            case .commonKeyContributor?:
                print("Contributor: \(item.value!)")
            case .commonKeyCopyrights?:
                print("Copyrights: \(item.value!)")
            case .commonKeyCreationDate?:
                print("CreationDate: \(item.value!)")
            case .commonKeyCreator?:
                print("creator: \(item.value!)")
            case .commonKeyDescription?:
                print("Description: \(item.value!)")
            case .commonKeyFormat?:
                print("Format: \(item.value!)")
            case .commonKeyIdentifier?:
                print("Identifier: \(item.value!)")
            case .commonKeyLanguage?:
                print("Language: \(item.value!)")
            case .commonKeyMake?:
                print("Make: \(item.value!)")
            case .commonKeyModel?:
                print("Model: \(item.value!)")
            case .commonKeyPublisher?:
                print("Publisher: \(item.value!)")
            case .commonKeyRelation?:
                print("Relation: \(item.value!)")
            case .commonKeySoftware?:
                print("Software: \(item.value!)")
            case .commonKeySubject?:
                print("Subject: \(item.value!)")
            case .commonKeyTitle?:
                print("Title: \(item.value!)")
            case .commonKeyType?:
                print("Type: \(item.value!)")
                
            case .id3MetadataKeyAlbumTitle?:
                print("id3MetadataKeyAlbumTitle: \(item.value!)")
                
            default:
                print("other data: \(item.value!)")
            }
        }
    }
    
    func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        for group in groups {
           // dump(group.items)
            for item in group.items {
                print("item identifier", item.identifier)
                if let seiData = item.value as? String {
                    dump(seiData)
                }
            }
        }
    }
    
    func readSEI() {
        playerItem = AVPlayerItem(asset: asset)

        // Create an instance of AVPlayerItemMetadataCollector and associate it with the AVPlayerItem
        let collector = AVPlayerItemMetadataCollector(identifiers: ["com.apple.streaming.supplemental_information"], classifyingLabels: nil)

        // Configure the AVPlayerItemMetadataCollector to collect SEI metadata
//        let identifier = AVMetadataIdentifier(rawValue: "com.apple.streaming.supplemental_information")
        collector.setDelegate(self, queue: DispatchQueue.main)
        playerItem.add(collector)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector, didCollect metadataGroups: [AVDateRangeMetadataGroup], indexesOfNewGroups: IndexSet, indexesOfModifiedGroups: IndexSet) {
        for group in metadataGroups {
            for metadataItem in group.items {
                if let identifier = metadataItem.identifier, identifier == AVMetadataIdentifier(rawValue: "com.apple.streaming.supplemental_information"), let data = metadataItem.dataValue {
                    // Process the SEI metadata here
                    print(data)
                }
            }
        }
        dump(metadataGroups)
    }
}

