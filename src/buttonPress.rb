require_relative "/koans/path_to_enlightenment"

$window = JS.global
$d = JS.global.document
saveButton = $d.createElement("button")
$d.body.appendChild(saveButton)

def getListOfKoans()
    storedFiles = JS::CodeStorage.instance.list_files
end

def getKoanCode(path)
    JS::CodeStorage.instance.retrieve_file(path)
end

def getCurrentKoanPath()
    currentKoanNumber = Integer(JS.global.localStorage.getItem("current_koan_number") || 0)
    koanPath = getListOfKoans.select { |path| path.include?($koans[currentKoanNumber]) }&.first
    
end

def loadCurrentKoanIntoEditor()
    koanPath = getCurrentKoanPath
    koanCode = getKoanCode(koanPath)
    $window.editor.setValue(koanCode)
    $window.editor.save
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
    $0 = File::basename(app_path, ".rb") if app_path
    
end

puts __FILE__

def pressButton
    if not $window.editor.getValue.to_s.empty?
        saveCurrentKoan
    end
    $response = ""
    def puts(*objects)
        objects.each do |text|
            $response += text.to_s + "\n"
        end
        super(objects)
    end
    def p(*objects)
        objects.each do |text|
            $response += text.to_s + "\n"
        end
        super(objects)
    end
    loadCurrentKoanIntoEditor()
    #app_path = getCurrentKoanPath
    #$0 = File::basename(app_path, ".rb") if app_path
    yield

    Neo::ThePath.new.walk
    $response
end