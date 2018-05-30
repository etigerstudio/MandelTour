//
//  MPIBroker.swift
//  MandelTour
//
//  Created by ALuier Bondar on 29/05/2018.
//  Copyright © 2018 E-Tiger Studio. All rights reserved.
//

import Foundation

class MPIBroker {
    static let shared = MPIBroker()
    let MPI_EXEC_PATH = "/usr/local/bin/orterun"
    let AGENT_EXEC_PATH = "/Users/ALuier/Library/Developer/Xcode/DerivedData/MandelAgent-covktswrdpodohdpcaqczwupdcap/Build/Products/Debug/MandelAgent"
    let TMP_DIR_PATH = NSTemporaryDirectory().appending("mandel.agent")
    private init() {}
    
    private var mpiProcess: Process?
    private var tmpDirectory: String?
    
    weak var viewDelegate: MandelViewDelegate?
    
    func spawnAgents(range: MandelRange, resX: Int, resY: Int) -> Bool {
        if let process = mpiProcess {
            if process.isRunning {
                return false
            }
        }
        guard settleTmpDir() else {
            return false
        }
        guard initProcess(range: range, resX: resX, resY: resY) else {
            return false
        }
        return true;
    }
    
    private func initProcess(range: MandelRange, resX: Int, resY: Int) -> Bool {
        mpiProcess = Process()
        //mpiProcess?.currentDirectoryPath = "/usr/local/bin"
        mpiProcess?.executableURL =
            URL(fileURLWithPath: MPI_EXEC_PATH)
        mpiProcess?.arguments = ["-n", "4", "-wd", TMP_DIR_PATH,
            AGENT_EXEC_PATH, "\(range.minR)", "\(range.maxR)",
            "\(range.minI)", "\(range.maxI)", "\(resX)", "\(resY)"]
        do {
            try mpiProcess?.run()
        } catch {
            print(error.localizedDescription)
            return false
        }
        DispatchQueue.global(qos: .background).async {
            self.waitOnRender()
        }
        return true
    }
    
    private func waitOnRender(){
        print("Waiting on MPI")
        self.mpiProcess?.waitUntilExit()
        print("MPI render completed!")
        guard let delegate = viewDelegate else {
            return
        }
        DispatchQueue.main.async {
            delegate.fetchRenderResults(path: self.TMP_DIR_PATH)
        }
    }
    
    private func settleTmpDir() -> Bool {
        print(TMP_DIR_PATH)
        let manager = FileManager.default
        var isDir = ObjCBool(false)
        if manager.fileExists(atPath: TMP_DIR_PATH,
                              isDirectory: &isDir) {
            if isDir.boolValue {
                return true
            } else {
                do {
                    try manager.removeItem(atPath: TMP_DIR_PATH)
                } catch {
                    return false
                }
            }
        } else {
            do {
                try manager.createDirectory(atPath: TMP_DIR_PATH, withIntermediateDirectories: true)
            } catch {
                return false
            }
            return true
        }
        return true
    }
}
