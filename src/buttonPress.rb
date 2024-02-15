require_relative "/koans/path_to_enlightenment"

$window = JS.global
$d = JS.global.document
saveButton = $d.createElement("button")
$d.body.querySelector(".buttons").appendChild(saveButton)
saveButton.innerText = "Beginners Mind"
saveButton.classList.add("reset")
saveButton.addEventListener("click") { 
    resetCurrentKoan() if $window.confirm("Do you want to start over?")   
 }

def getListOfKoans()
    storedFiles = JS::CodeStorage.instance.list_files
end

def getKoanCode(path)
    JS::CodeStorage.instance.retrieve_file(path)
end

def switchToPassingKoanInStorage()
    currentKoanFilename = $thePath.currentKoanFile 
    #puts "currentKoanFilename #{currentKoanFilename}"
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

def markError
    # get the error file / error position
    # doc.markText
    # doc.markText(from: {line, ch}, to: {line, ch}, ?options: object) → TextMarker
    #Can be used to mark a range of text with a specific CSS class name. from and to should be {line, ch} objects. The options parameter is optional. When given, it should be an object that may contain the following configuration options:

    #className: string
        #Assigns a CSS class to the marked stretch of text.
    
    editor = $window.editor
    line_number = $thePath.sensei.getLineAndError&.fetch(:line_number)&.to_i
    line_value = editor.getValue&.to_s&.lines&.fetch(line_number - 1)&.chomp
    if line_number and line_value
        firstNonWhitespaceCharacter =  line_value.index(/\S/).to_i
        editor.markText({:line => line_number - 1, :ch => firstNonWhitespaceCharacter}, {:line => line_number - 1, :ch => line_value.length}, {:className => "marker" })

        scrollToLine = line_number + 5
        scrollToLine = 0 if scrollToLine.negative?
        #editor.scrollIntoView({line: scrollToLine, char: firstNonWhitespaceCharacter}, 200)
        editor.scrollToRange({:line => line_number - 1, :ch => firstNonWhitespaceCharacter}, {:line => line_number - 1, :ch => line_value.length})
    end
end

# def switchKoan(thePath)
#     currentKoanFilePath = "/koans/" + thePath.getCurrentKoanFile + ".rb"
#     koanCode = getKoanCode(currentKoanFilePath)
#     loadCodeIntoEditor(koanCode)
# end

def updateTemplate(sensei)
    #temp = $response.clone # dont output anything
    $d.getElementById("encourageHeader").innerText = sensei.a_zenlike_statement(print: false)
    $d.getElementById("currentFile").innerText = File.basename(getCurrentKoanPath)
    guide = sensei.guide_through_error_data
    $d.getElementById("zenMasterText").innerHTML = "#{guide[:answers]}, #{guide[:failureMessage]}, #{guide[:meditate]}, #{guide[:code]}"

    #$response = temp

    #encourageData
    #guide_through_error_data

    markError
end

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
    sensei = thePath.sensei
    updateTemplate(sensei)
    
    # if the koans is done this will load the next one
    loadCurrentKoanIntoEditor()
    updateTemplate(sensei)

    $response
end

$window.addEventListener("keydown") do |event|
    if (event.altKey && event.key === 'r') 
        event.preventDefault()
        #$d.getElementById("run-code").click
        click_run_button()
    end
end