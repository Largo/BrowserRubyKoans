require_relative "/koans/path_to_enlightenment"
require "singleton"

class KoanWeb
    include Singleton

    def initialize()

        $window = JS.global
        $d = JS.global.document

        setUpElements
        
    end

    def setupCodemirror()
          # Access the code area and set up the CodeMirror editor
          code_area = JS.global.document.getElementById("ruby-code")
          $window.editor = $window[:CodeMirror].fromTextArea(code_area, {
              lineNumbers: true,
              mode: "text/x-ruby",
              matchBrackets: true,
              indentUnit: 4
          })
    end

    def setUpElements()
        setupCodemirror
      

        $d.createElement("button").tap do |saveButton|
            saveButton.innerText = "Beginners Mind"
            saveButton.classList.add("reset")
            saveButton.addEventListener("click") { 
                resetCurrentKoan() if $window.confirm("Do you want to start over?")   
            }
            $d.body.querySelector(".buttons").appendChild(saveButton)
        end
        
        $d.querySelector(".spinner").style.display = "none";

         # Set up the event listener for the run code button
        JS.global.document.getElementById("run-code").addEventListener("click") do |e|
            clickRunButton()
        end
        
        $window.addEventListener("keydown") do |event|
            if (event.altKey && event.key === 'r') 
                event.preventDefault()
                #$d.getElementById("run-code").click
                clickRunButton()
            end
        end
    end

    def clickRunButton()
        code_area = $d.getElementById("ruby-code")
        $window.editor.save
        output_div = $d.getElementById("output")
        code = <<-RUBY
        KoanWeb.instance().pressButton {
            #{code_area.value}
        }
        RUBY

        begin
            output_div.innerHTML = Kernel.eval(code.strip, ::Object::TOPLEVEL_BINDING, __FILE__ + "_eval")
        rescue => e
            output_div.innerHTML = e.to_s
        end
    end

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

    def markError
        editor = $window.editor
        line_number = $thePath.sensei.getLineAndError&.fetch(:line_number)&.to_i
        line_value = editor.getValue&.to_s&.lines&.fetch(line_number - 1)&.chomp
        if line_number and line_value
            firstNonWhitespaceCharacter =  line_value.index(/\S/).to_i
            editor.markText({:line => line_number - 1, :ch => firstNonWhitespaceCharacter}, {:line => line_number - 1, :ch => line_value.length}, {:className => "marker" })

            scrollToLine = line_number 
            scrollToLine = 0 if scrollToLine.negative?
            editor.scrollIntoView({line: scrollToLine, char: firstNonWhitespaceCharacter}, 200)
            #editor.scrollToRange({:line => line_number - 1, :ch => firstNonWhitespaceCharacter}, {:line => line_number - 1, :ch => line_value.length})
        end
    end

    # def switchKoan(thePath)
    #     currentKoanFilePath = "/koans/" + thePath.getCurrentKoanFile + ".rb"
    #     koanCode = getKoanCode(currentKoanFilePath)
    #     loadCodeIntoEditor(koanCode)
    # end

    def updateTemplate(sensei)
        $d.getElementById("encourageHeader").innerText = sensei.a_zenlike_statement(print: false)
        $d.getElementById("currentFile").innerText = File.basename(getCurrentKoanPath)
        guide = sensei.guide_through_error_data
        $d.querySelector("#zenMasterChat").tap do |e| 
            masterText = "#{guide[:answers]} <br> #{guide[:meditate]} <br> #{guide[:code]} <br> #{guide[:failureMessage]}"

            data = sensei.encourageData
            masterText += "<br><br> #{data[:progressText]}"
        
            e.querySelector("#zenMasterText").innerHTML = masterText      
            e.style.display = "flex"
        end
    end

    def firstTimeRun
        loadCurrentKoanIntoEditor
    end

    def overridePutMethods
        $response = ""
        # Redefine output methods to catch their output

        methods_to_override = [:puts, :p, :print]
        methods_to_override.each do |original_method|
            Kernel.module_eval do
                alias_method :"original_#{original_method}", original_method
                define_method(original_method) do |*args|
                    parameters = *args.map { _1.to_s }
                    parameters.each do |text|
                        $response += text.to_s
                        $response += "\n" unless original_method == :print
                    end
                    send(:"original_#{original_method}", *args)
                end
            end
        end
    end

    def resetPutMethods
        # List of methods to reset to their original behavior
        methods_to_reset = [:puts, :p, :print]

        methods_to_reset.each do |original_method|
            Kernel.module_eval do
                # Redefine the method to call its original implementation directly
                define_method(original_method, Kernel.instance_method("original_#{original_method}"))
            end
        end
    end

    def pressButton
        if not $window.editor.getValue.to_s.empty?
            saveCurrentKoan
        end
        $thePath = thePath = Neo::ThePath.new
        thePath.walk(false)
        switchToPassingKoanInStorage

        overridePutMethods
    
        loadCurrentKoanIntoEditor()
        JS::CodeStorage.instance.run_file(getCurrentKoanPath)

        thePath.walk
        sensei = thePath.sensei
        updateTemplate(sensei)
        
        # if the koans is done this will load the next one
        switchToPassingKoanInStorage
        loadCurrentKoanIntoEditor()
        updateTemplate(sensei)

        markError

        resetPutMethods

        $response
    end
end


