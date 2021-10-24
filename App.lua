require('Misc')
require('Utils')

App = {
    tabWidth = 0,
    tabHeight = 0,
    navWidth = 0,
    navHeight = 0
}

-- 导航条
local tabX, tabY =
    findMultiColorInRegionFuzzy(
    0xd2d2d2,
    '5|0|0xd2d2d2,16|0|0xd2d2d2,35|0|0xd2d2d2,76|0|0xd2d2d2,126|0|0xd2d2d2,172|0|0xd2d2d2',
    Misc.high,
    0,
    Misc.screenHeight / 5 * 4,
    Misc.screenWidth,
    Misc.screenHeight
)
Utils.checkFailed(tabX, '[error](错误，未找到导航条，程序退出！)')

App.tabWidth = Misc.screenWidth
App.tabHeight = Misc.screenHeight - tabY
App.statusHeight = 50

App.navWidth = App.tabWidth
App.navHeight = App.tabHeight
nLog('[](导航条高度:)', App.tabHeight)

App.back = function(self, type)
    local retryTimes = 0

    ::backRetry::
    mSleep(1000)

    local color, colorArea

    -- 0文章
    -- 1视频
    if type == 0 then
        color = 0x000000
        colorArea =
            '-5|5|0x000000,-9|9|0x000000,-12|12|0x000000,-15|15|0x000000,-13|18|0x000000,-10|21|0x000000,-8|23|0x000000,-6|25|0x000000,0|31|0x000000'
    elseif type == 1 then
        color = 0xffffff
        colorArea =
            '-5|5|0xffffff,-9|9|0xffffff,-12|12|0xffffff,-15|15|0xffffff,-13|18|0xffffff,-10|21|0xffffff,-8|23|0xffffff,-6|25|0xffffff,0|31|0xffffff'
    end

    local x, y = findMultiColorInRegionFuzzy(color, colorArea, Misc.high, 0, 0, Misc.screenWidth, self.navHeight * 2)

    if x == -1 then
        if retryTimes >= 1 then
            -- Utils.checkFailed(-1, '未找到视频')
            return toast('[wraning](未找到返回按钮！)')

        -- TODO 未找到返回按钮，可以尝试重启App
        end

        retryTimes = retryTimes + 1
        goto backRetry
    end

    nLog('[](找到返回按钮)' .. x .. ' ' .. y)
    Utils.click(x, y)
end

App.isBack = function(self, type)
    local color, colorArea
    if type == 0 then
        color = 0x000000
        colorArea =
            '-5|5|0x000000,-9|9|0x000000,-12|12|0x000000,-15|15|0x000000,-13|18|0x000000,-10|21|0x000000,-8|23|0x000000,-6|25|0x000000,0|31|0x000000'
    elseif type == 1 then
        color = 0xffffff
        colorArea =
            '-5|5|0xffffff,-9|9|0xffffff,-12|12|0xffffff,-15|15|0xffffff,-13|18|0xffffff,-10|21|0xffffff,-8|23|0xffffff,-6|25|0xffffff,0|31|0xffffff'
    end

    local x, y = findMultiColorInRegionFuzzy(color, colorArea, Misc.high, 0, 0, Misc.screenWidth, self.navHeight * 2)

    return x ~= -1
end

App.restart = function()
    local qiangId = 'cn.xuexi.android'
    --检测是否在运行
    local flag = appIsRunning(qiangId)

    toast('[](尝试重启应用)', 1)
    nLog('[](尝试重启应用)')
    --如果没有运行
    if flag == 0 then
        --运行
        return runApp(qiangId)
    end

    closeApp(qiangId)

    mSleep(2 * 1000)

    runApp(qiangId)
end

App.waitLunch = function(self)
    local i = 0
    while true do
        if i > 20 then
            error('[error](无法获取到进入App状态！)')
        end

        mSleep(1000)
        local x, y =
            findMultiColorInRegionFuzzy(
            0xe32416,
            '-36|27|0xe32416,-1|27|0xe32416,30|27|0xe32416,-7|46|0xe32416',
            Misc.high,
            0,
            Misc.screenHeight - self.navHeight,
            Misc.screenWidth,
            Misc.screenHeight
        )

        if x ~= -1 then
            break
        end

        i = i + 1
    end

    toast('[](进入App)', 1)
    nLog('[](进入App)')
end
