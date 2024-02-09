require_relative "/koans/path_to_enlightenment"

$window = JS.global
$d = JS.global.document
saveButton = $d.createElement("button")
$d.body.querySelector(".buttons").appendChild(saveButton)
saveButton.innerText = "Beginners Mind"
saveButton.addEventListener("click") { resetCurrentKoan() }

def getListOfKoans()
    storedFiles = JS::CodeStorage.instance.list_files
end

def getKoanCode(path)
    JS::CodeStorage.instance.retrieve_file(path)
end

def switchToPassingKoanInStorage()
    currentKoanFilename = $thePath.currentKoanFile 
    puts "currentKoanFilename #{currentKoanFilename}"
    return 0 if currentKoanFilename.to_s == ""
    currentKoanFilePath = "/koans/" + currentKoanFilename + ".rb"
    if getListOfKoans.include?(currentKoanFilePath)
      currentKoan = currentKoanFilePath
      JS.global.localStorage.setItem("current_koan", currentKoan)
    end
end

def getCurrentKoanPath()
    currentKoan = JS.global.localStorage.getItem("current_koan").to_s
    currentKoan = $koans[0] if currentKoan == ""
    koanPath = getListOfKoans.select { |path| path.include? currentKoan }&.first
end

def loadCodeIntoEditor(koanCode)
    $window.editor.setValue(koanCode)
    $window.editor.save
end

def loadCurrentKoanIntoEditor()
    koanPath = getCurrentKoanPath
    koanCode = getKoanCode(koanPath)
    loadCodeIntoEditor(koanCode)
end

def resetCurrentKoan()
    puts "resetcurrentkoan"
    koanPath = getCurrentKoanPath
    originalKoanCode = JS::CodeStorage.instance.retrieve_original_file(koanPath)
    JS::CodeStorage.instance.save_file(koanPath, originalKoanCode)
    loadCurrentKoanIntoEditor()
end

def saveCurrentKoan()
    koanPath = getCurrentKoanPath
    koanCode = $window.editor.getValue
    JS::CodeStorage.instance.save_file(koanPath, koanCode)
end

def changeFile(newFile, &block)
    oldFile = __FILE__
    app_path = newFile
    $0 = File::basename(app_path, ".rb") if app_path
end

def compareOriginalTo(code)

end

# def switchKoan(thePath)
#     currentKoanFilePath = "/koans/" + thePath.getCurrentKoanFile + ".rb"
#     koanCode = getKoanCode(currentKoanFilePath)
#     loadCodeIntoEditor(koanCode)
# end

def pressButton
    if not $window.editor.getValue.to_s.empty?
        saveCurrentKoan
    end
    $thePath = thePath = Neo::ThePath.new
    thePath.walk
    switchToPassingKoanInStorage
    $response = ""
    def appendToOutput(*objects)
        objects.each do |text|
            $response += text.to_s
        end
    end
    def print(*objects)
        appendToOutput(*objects.map { _1.to_s })
        super(objects)
    end
    def puts(*objects)
        appendToOutput(*objects.map { _1.to_s + "\n" })
        super(objects)
    end
    def p(*objects)
        appendToOutput(*objects.map { _1.to_s + "\n" })
        super(objects)
    end
    loadCurrentKoanIntoEditor()
    #app_path = getCurrentKoanPath
    #$0 = File::basename(app_path, ".rb") if app_path
    #yield
    JS::CodeStorage.instance.run_file(getCurrentKoanPath)

    thePath.walk
    sensei = Neo::Sensei.new
    $d.getElementById("encourageHeader").innerText = sensei.a_zenlike_statement
    
    # if the koans is done this will load the next one
    loadCurrentKoanIntoEditor()

    $response
end

