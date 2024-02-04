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

    puts __FILE__

    yield

    require_relative "/koans/path_to_enlightenment"
    Neo::ThePath.new.walk
    $response
end