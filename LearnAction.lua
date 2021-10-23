require('Utils')
require('Misc')
require('App')

-- 学习动作
LearnAction = {}

-- 观看视频
LearnAction.Video = {waitTime = 0, readRetryTimes = 0}

LearnAction.Video.init = function(self)
    -- self.waitTime = 60 * 6
    self.waitTime = 1
    self.readRetryTimes = 0
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

    toast('[](当前休息中，观看视频6分钟)', self.waitTime)
    nLog('[](当前休息中，观看视频6分钟)')
    mSleep(self.waitTime * 1001)
    App:back(1)
end

-- 阅读文章
LearnAction.Artical = {
    baseX = 0,
    baseY = 0,
    navX = nil,
    navY = nil,
    readRetryTimes = 0,
    startTime = 0,
    eachArticalSpeedTime = 0
}

LearnAction.Artical.init = function(self)
    -- 导航条
    local navX, navY =
        findMultiColorInRegionFuzzy(
        0xd2d2d2,
        '5|0|0xd2d2d2,16|0|0xd2d2d2,35|0|0xd2d2d2,76|0|0xd2d2d2,126|0|0xd2d2d2,172|0|0xd2d2d2',
        Misc.high,
        0,
        Misc.screenHeight / 5 * 4,
        Misc.screenWidth,
        Misc.screenHeight
    )
    Utils.checkFailed(navX, '[error](错误，未找到导航条，程序退出！)')

    nLog('[](导航条高度x, y)', navX, navY, Misc.screenHeight - navY)
    self.navX = navX
    self.navY = navY

    -- 文章上线基点
    local baseX, baseY =
        findMultiColorInRegionFuzzy(
        0xf2f3f5,
        '36|0|0xf2f3f5,81|0|0xf2f3f5,135|0|0xf2f3f5,172|0|0xf2f3f5',
        Misc.high,
        0,
        self.baseY,
        Misc.screenWidth,
        Misc.screenHeight
    )
    Utils.checkFailed(baseX, '[error](错误，未找到初始点，程序退出！)')

    nLog('[](基线上线x, y)', baseX, baseY)
    self.baseX = baseX
    self.baseY = baseY + 1

    self.startTime = os.time()
    -- 每篇文章需要60秒钟
    -- self.eachArticalSpeedTime = 60
    -- self.totalArtical = 6
    self.eachArticalSpeedTime = 1
    self.totalArtical = 6
end

LearnAction.Artical.read = function(self, targetX, targetY)
    Utils.click(targetX, targetY)

    ::read::
    mSleep(1000)

    -- 判断文章页面上线

    local i = 0
    local direction = 1 -- 滑动方向默认向下

    -- x1, y1, x2, y2为文章可视区域
    local x1, y1 = Misc.screenWidth / 2, self.navY - (Misc.screenHeight - self.navY) * 0.5
    local x2, y2 = x1, (Misc.screenHeight - self.navY) * 2

    -- TODO 判断是否在文章页面
    local inArticalX, inArticalY =
        findMultiColorInRegionFuzzy(
        0x000000,
        '191|-4|0xe32416,-14|15|0x000000,194|23|0xe32416,0|31|0x000000',
        Misc.high,
        0,
        0,
        Misc.screenWidth,
        y1
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
            Utils.moveTo(x1, y1, x2, y2)
            i = i + 1
        else
            Utils.moveTo(x2, y2, x1, y1)
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

    local i = 0
    while true do
        if i > self.totalArtical then
        end

        ::loop::
        mSleep(500)

        nLog('[info](当前基点:)' .. self.baseX .. ' ' .. self.baseY)
        local x2, y2 =
            findMultiColorInRegionFuzzy(
            0xf2f3f5,
            '36|0|0xf2f3f5,81|0|0xf2f3f5,135|0|0xf2f3f5,172|0|0xf2f3f5',
            Misc.high,
            0,
            self.baseY,
            Misc.screenWidth,
            Misc.screenHeight
        )

        nLog('[info](x1, y1, x2, y2:)' .. self.baseX .. ' ' .. self.baseY .. ' ' .. x2 .. ' ' .. y2)
        if x2 == -1 then
            nLog('[info](未找到文章下线，下拉数据)')

            -- 第一种：下拉刷新数据
            -- moveTo(
            --     Misc.screenWidth / 2,
            --     Misc.screenHeight / 3,
            --     Misc.screenWidth / 2,
            --     Misc.screenHeight / 3 + Misc.screenHeight / 3
            -- )

            -- 第二种：向下滑动
            local distanceY = self.navY - (Misc.screenHeight - self.navY)
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

            mSleep(1500)
            goto loop
        end

        -- local tmpBaseX = self.basex
        local tmpBaseY = self.baseY - 1

        self.baseX = x2
        self.baseY = y2 + 1

        local x3, y3 =
            findMultiColorInRegionFuzzy(
            0x0a062f,
            '13|0|0xffffff,28|0|0x0f0b2e,2|3|0x0b062f,14|3|0xffffff,31|3|0x100b2f,1|9|0x0c0630,11|9|0xffffff,24|9|0x0e0a30',
            Misc.middle,
            0,
            tmpBaseY,
            Misc.screenWidth,
            self.baseY - 1
        )
        if x3 ~= -1 then
            nLog('[]找到x3, y3, baseX, baseY:' .. x3 .. ' ' .. y3 .. self.baseX .. ' ' .. self.baseY)

            goto loop
        end

        -- 区域内，垂直(y)方向上的中点
        local targetX, targetY = Misc.screenWidth / 2, (self.baseY - tmpBaseY) / 2 + tmpBaseY

        nLog('[](找到文章:)')
        -- nLog(x .. ' ' .. y)
        -- nLog(x2 .. ' ' .. y2)
        -- nLog(x3 .. ' ' .. y3)
        nLog(targetX .. ' ' .. targetY)

        -- 阅读文章
        self:read(targetX, targetY)

        -- 返回
        -- Utils.click(47, 99)
        App:back(0)
        i = i + 1
    end
end
