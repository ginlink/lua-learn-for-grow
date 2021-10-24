require 'TSLib'
require('LearnAction')
require('App')
require('Misc')

function main()
    App:restart()
    App:waitLunch()
    LearnAction.Video:start()

    App:restart()
    App:waitLunch()
    LearnAction.Artical:start()

    -- local articalRangeX, articalRangeY =
    --     findMultiColorInRegionFuzzy(
    --     0xffffff,
    --     '-1|3|0xe32416,-17|14|0xe42c1e,10|14|0xe42e20,-1|24|0xe32416,-10|23|0xffffff',
    --     Misc.high,
    --     0,
    --     App.navHeight * 2,
    --     Misc.screenWidth,
    --     Misc.screenHeight - App.navHeight
    -- )

    -- nLog(articalRangeX .. ' ' .. articalRangeY)
end

main()
