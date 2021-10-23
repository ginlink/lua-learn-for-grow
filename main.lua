require('LearnAction')

function main()
    App:restart()
    App:waitLunch()
    LearnAction.Video:start()

    App:restart()
    App:waitLunch()
    LearnAction.Artical:start()
end

main()
