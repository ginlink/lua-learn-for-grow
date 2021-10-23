require 'TSLib'
--使用本函数库必须在脚本开头引用并将文件放到设备 lua 目录下

Utils = {}

Utils.click = function(x, y)
    tap(x, y, 50)
end

Utils.moveTo = function(startX, startY, endX, endY)
    moveTo(startX, startY, endX, endY)
end

Utils.checkFailed = function(x, text)
    if x == -1 then
        error(text)
    end
end
