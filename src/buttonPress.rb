
def getListOfKoans()
    storedFiles = JS::CodeStorage.instance.list_files
end

def pressButton
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

    yield

    require_relative "/koans/path_to_enlightenment"
    Neo::ThePath.new.walk
    $response
end