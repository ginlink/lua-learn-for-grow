require('Utils')
require('Misc')
require('App')

-- 学习动作
LearnAction = {}

-- 观看视频
LearnAction.Video = {waitTime = 0, readRetryTimes = 0}

LearnAction.Video.init = function(self)
    self.waitTime = 60 * 6
    -- self.waitTime = 1
    self.readRetryTimes = 1
end
LearnAction.Video.start = function(self)
    self:init()

    toast('[Video](开始执行)', 1)

    -- 百灵，判断，点击
    local x, y = findMultiColorInRegionFuzzy(0xabb3ba, '-3|-16|0xabb3ba,19|1|0xabb3ba', 90, 178, 1190, 260, 1279)
    Utils.checkFailed(x, '[失败](未找到百灵)')
    Utils.click(x, y)

    ::video::
    mSleep(1000)

    -- 视频窗口范围，点击，等待6.5分钟
    local videoX, videoY =
        findMultiColorInRegionFuzzy(
        0xabb3ba,
        '-13|19|0xabb3ba,3|19|0xffffff,15|19|0xabb3ba,3|26|0xabb3ba',
        Misc.high,
        0,
        App.navHeight,
        Misc.screenWidth,
        Misc.screenHeight - App.tabHeight
    )

    if videoX == -1 then
        -- 只允许重试阅读一次
        if self.readRetryTimes >= 1 then
            -- Utils.checkFailed(-1, '未找到视频')
            return toast('[wraning](未找到视频！)')
        end

        self.readRetryTimes = self.readRetryTimes + 1
        goto video
    end

    self.readRetryTimes = 0
    Utils.click(Misc.screenWidth / 2, (videoY - App.navHeight) / 2)

    mSleep(1000)
    if App:isBack(1) == false then
        mSleep(1000)
        if App:isBack(1) == false then
            goto video
        end
    end

    toast('[](当前休息中，观看视频6分钟)', self.waitTime)
    nLog('[](当前休息中，观看视频6分钟)')
    mSleep(self.waitTime * 1001)
    App:back(1)
end

-- 阅读文章
LearnAction.Artical = {
    baseX = nil,
    baseY = nil,
    readRetryTimes = 0,
    startTime = 0,
    eachArticalSpeedTime = 0,
    reset = true
}

LearnAction.Artical.init = function(self)
    self.startTime = os.time()
    -- 每篇文章需要60秒钟
    self.eachArticalSpeedTime = 60
    self.totalArtical = 6

    -- self.eachArticalSpeedTime = 1
    -- self.totalArtical = 6
end

LearnAction.Artical.read = function(self, targetX, targetY)
    mSleep(1000)
    Utils.click(targetX, targetY)

    ::read::
    mSleep(1000)

    -- 判断文章页面上线

    local i = 0
    local direction = 1 -- 滑动方向默认向下

    -- 顶部导航上下线
    local rangeLower = (App.navHeight * 2) + App.statusHeight
    local rangeUpper = Misc.screenHeight - App.navHeight

    -- x1, y1, x2, y2为文章可视区域
    local x1, y1 = Misc.screenWidth / 2, rangeLower
    local x2, y2 = x1, rangeUpper - 10

    -- TODO 判断是否在文章页面(黑喇叭)
    local inArticalX, inArticalY =
        findMultiColorInRegionFuzzy(
        0xfafbfc,
        '14|0|0x000000,-8|15|0x000000,5|15|0xfafbfc,14|15|0x000000,27|15|0x000000,13|31|0x000000',
        Misc.high,
        0,
        App.statusHeight,
        Misc.screenWidth,
        rangeLower
    )
    if inArticalX == -1 then
        -- 只允许重试阅读一次
        if self.readRetryTimes >= 1 then
            return nLog('[](未在文章页面，继续下一篇文章)')
        end

        self.readRetryTimes = self.readRetryTimes + 1
        goto read
    end

    self.readRetryTimes = 0
    local startTime = os.time()

    while i >= 0 do
        if direction > 0 then
            Utils.moveTo(x2, y2, x1, y1)
            i = i + 1
        else
            Utils.moveTo(x1, y1, x2, y2)
            i = i - 1
        end

        local articalEndX, articalEndY =
            findMultiColorInRegionFuzzy(
            0xf5f5f7,
            '271|5|0xf5f5f7,-2|49|0xf5f5f7,269|53|0xf5f5f7',
            Misc.high,
            0,
            y1,
            Misc.screenWidth,
            y2
        )

        -- 红色矩形
        local redRectX, redRectY =
            findMultiColorInRegionFuzzy(
            0xe32416,
            '5|0|0xe32416,0|11|0xe32416,5|11|0xe32416,0|24|0xe32416,5|24|0xe32416',
            Misc.high,
            0,
            y1,
            Misc.screenWidth,
            y2
        )

        if articalEndX ~= -1 or redRectX ~= -1 then
            -- 改变方向
            direction = -1
            i = i - 1
        end

        local endTime = os.time()
        local speedTime = endTime - startTime
        if (speedTime > self.eachArticalSpeedTime) then
            break
        end
        mSleep(500)
    end

    local endTime = os.time()
    local speedTime = endTime - startTime

    nLog('[]' .. speedTime .. ' ' .. self.eachArticalSpeedTime)

    if (speedTime > self.eachArticalSpeedTime) then
        return
    else
        toast('[](当前未满足文章阅读时间，休息中...)', self.eachArticalSpeedTime - speedTime)
        mSleep((self.eachArticalSpeedTime - speedTime) * 1000)
    end
end

LearnAction.Artical.entryArticles = function(self)
    mSleep(1000)
    Utils.click(538, 186)
    mSleep(1000)
end

LearnAction.Artical.start = function(self)
    self:init()
    self:entryArticles()

    -- 12分，6篇文章提留10秒，共60秒，最后提留5.5

    local rangeLower = (App.navHeight * 2) + App.statusHeight
    local rangeUpper = Misc.screenHeight - App.navHeight
    local i = 0
    while true do
        if i > self.totalArtical then
            error('[success](阅读文章完毕！)')
        end

        ::loop::
        mSleep(1500)

        if self.reset then
            self.reset = false

            local baseUpperX, baseUpperY =
                findMultiColorInRegionFuzzy(
                0xf2f3f5,
                '124|0|0xf2f3f5,431|0|0xf2f3f5,568|0|0xf2f3f5,631|0|0xf2f3f5,0|1|0xffffff,142|1|0xffffff,429|1|0xffffff,647|1|0xffffff',
                Misc.high,
                0,
                rangeLower,
                Misc.screenWidth,
                rangeUpper
            )

            -- nLog('[](文章区域)' .. rangeLower .. ' ' .. rangeUpper)
            -- Utils.checkFailed(baseX, '[error](错误，未找到初始点，程序退出！)')
            if baseUpperY == -1 then
                nLog('[info](未找到文章上线，滑动)')

                local distanceY = Misc.screenHeight - App.navHeight * 1.3

                moveTo(Misc.screenWidth / 2, distanceY, Misc.screenWidth / 2, 0)

                goto loop
            end

            nLog('[](基线上线y)' .. baseUpperY)
            self.baseX = baseUpperX
            self.baseY = baseUpperY + 5

            mSleep(500)
        end

        -- local rangeLower = (App.navHeight * 2) + App.statusHeight
        -- local rangeUpper = Misc.screenHeight - App.navHeight
        local baseLowerX, baseLowerY =
            findMultiColorInRegionFuzzy(
            0xf2f3f5,
            '124|0|0xf2f3f5,431|0|0xf2f3f5,568|0|0xf2f3f5,631|0|0xf2f3f5,0|1|0xffffff,142|1|0xffffff,429|1|0xffffff,647|1|0xffffff',
            Misc.high,
            0,
            -- 以上一次基点线为基础向下找
            self.baseY,
            Misc.screenWidth,
            rangeUpper
        )

        if baseLowerY == -1 then
            nLog('[info](未找到文章下线，下拉数据)')

            -- 第一种：下拉刷新数据
            -- moveTo(
            --     Misc.screenWidth / 2,
            --     Misc.screenHeight / 3,
            --     Misc.screenWidth / 2,
            --     Misc.screenHeight / 3 + Misc.screenHeight / 3
            -- )

            -- 第二种：向下滑动
            local distanceY = Misc.screenHeight - App.navHeight * 1.3

            moveTo(Misc.screenWidth / 2, distanceY, Misc.screenWidth / 2, 0)

            -- TODO 等待刷新完毕，并检查网络
            -- local loadX, loadY =
            --     findMultiColorInRegionFuzzy(
            --     0xe32416,
            --     '-15|16|0xe32416,1|16|0xffffff,16|16|0xe32416,1|31|0xe32416',
            --     Misc.high,
            --     564,
            --     565,
            --     718,
            --     635
            -- )

            -- 重置状态
            self.baseX = 0
            self.baseY = 0
            self.reset = true

            goto loop
        end

        -- 缓存上线
        local baseUpperY = self.baseY

        nLog('[](基线下线y)' .. baseLowerY)
        self.baseX = baseLowerX
        self.baseY = baseLowerY + 5

        -- local mediaX, mediaY =
        --     findMultiColorInRegionFuzzy(
        --     0xe32416,
        --     '7|0|0xe32416,0|31|0xe32416,7|31|0xe32416,3|11|0xe32416,-3|0|0xffffff,9|34|0xffffff',
        --     90,
        --     0,
        --     App.navHeight * 2,
        --     Misc.screenWidth,
        --     Misc.screenHeight - App.navHeight
        -- )

        -- if mediaX ~= -1 then
        --     -- 滑动
        --     local distanceY = App.navHeight - (Misc.screenHeight - App.navHeight)

        --     moveTo(Misc.screenWidth / 2, distanceY, Misc.screenWidth / 2, 0)

        --     -- 重置状态
        --     self.baseX = 0
        --     self.baseY = 0
        --     mSleep(1500)
        --     goto loop
        -- end

        -- 是否为文章区间(喇叭为依据)
        local articalRangeX, articalRangeY =
            findMultiColorInRegionFuzzy(
            0xffffff,
            '-1|3|0xe32416,-17|14|0xe42c1e,10|14|0xe42e20,-1|24|0xe32416,-10|23|0xffffff',
            Misc.high,
            0,
            baseUpperY,
            Misc.screenWidth,
            baseLowerY
        )

        if articalRangeX == -1 then
            -- 滑动
            local distanceY = Misc.screenHeight - App.navHeight * 1.3

            moveTo(Misc.screenWidth / 2, distanceY, Misc.screenWidth / 2, 0)

            -- 重置状态
            self.baseX = 0
            self.baseY = 0
            self.reset = true

            mSleep(1500)
            goto loop
        end

        -- 区域内，垂直(y)方向上的中点
        local targetX, targetY = Misc.screenWidth / 2, (baseLowerY - baseUpperY) / 2 + baseUpperY

        nLog('[](找到文章:)' .. targetX .. ' ' .. targetY)

        -- 阅读文章
        self:read(targetX, targetY)

        -- 返回
        -- Utils.click(47, 99)
        mSleep(1000)
        App:back(0)
        i = i + 1
    end
end
