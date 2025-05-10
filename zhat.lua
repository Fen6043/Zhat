-- 0.4.2

function contains(list, target)
    for _, value in ipairs(list) do
        if value == target then
            return true
        end
    end
    return false
end

function ping(sentToNumber)
    while true do
        if sentToNumber == 3 then
            modem.transmit(sentToNumber,myNumber,"#ping" .. version)
        else
            modem.transmit(sentToNumber,myNumber,"#ping")
        end
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        if replyChannel == sentToNumber and channel == myNumber and message == "#active" then
            -- term.setTextColor(colors.green)
            -- print("\nuser is online")
            active = true
            term.setTextColor(colors.white)
            return
        elseif replyChannel == sentToNumber and channel == myNumber and message == "#update" then
            term.clear()
            shell.run("update")
            error("zhat updated please reboot the device",0)
        end
    end
end

function pingTimer(sentToNumber)
    term.setTextColor(colors.yellow)
    os.sleep(3)
    -- write("pinging")
    -- for i = 0, 3, 1 do
    --     write('.')
    --     os.sleep(1)
    -- end
    term.setTextColor(colors.red)
    if sentToNumber == 3 then
        term.clear()
        error("Server is down",0)
    else
        print("user is offline\n")
    end
    inx,iny = term.getCursorPos()
    term.setTextColor(colors.white)
end

function printToScreen(text)
    local width,height = term.getSize()
    local x,y = inx,iny
    term.setCursorPos(1,y)
    term.write("> ")
    local j = 3
    for i = 1, #text do
        term.write(string.sub(text,i,i))
        j = j + 1
        if j > width then
            j = 5
            y = y + 1
            if y > height then
                term.scroll(1)
                inx = inx - 1
                iny = iny - 1
                y = y-1
            end
            term.setCursorPos(5,y)
        end
    end
end

autoFill = false
keyword = ""

function readKey()
    while true do
        local event, key, is_held = os.pullEvent("key")
        -- print(keys.getName(key))
        if keys.getName(key) == "enter" then
            print("")
            break
        elseif keys.getName(key) == "backspace" and input ~= "" then
            input = string.sub(input, 1, #input - 1)
            if autoFill then
                keyword = string.sub(keyword, 1, #input - 1)
            end
            local x,y = term.getCursorPos()
            while y >= iny do
                term.setCursorPos(1,y)
                term.clearLine()
                y = y - 1
            end
            printToScreen(input)
        elseif keys.getName(key) == "up" or keys.getName(key) == "down" then
            local buffer = previnput
            previnput = input
            input = buffer
            local x,y = term.getCursorPos()
            while y >= iny do
                term.setCursorPos(1,y)
                term.clearLine()
                y = y - 1
            end
            printToScreen(input)
        end
    end
end

function readInput()
    local finishcall = {["f"] = "Fenrir ", ["ray"] = "Rayn ", ["rae"] = "Rae "}
    while true do
        local event, character = os.pullEvent("char")
        if readInputToggle then
            if autoFill then
                if character == " " then
                    input = input .. character
                    autoFill = false
                    keyword = ""
                else
                    keyword = keyword .. character
                    if finishcall[string.lower(keyword)] then
                        input = "@" .. finishcall[string.lower(keyword)]
                        keyword = ""
                        autoFill = false
                    else
                        input = input .. character
                    end
                end
            else
                if character == "@" and input == "" then
                    input = "@"
                    autoFill = true
                elseif character == "/"  and input == "" then
                    input = "/exit"
                    printToScreen(input)
                elseif character == "#" then
                    local x,y,z = gps.locate()
                    input = input .. math.floor(x) .. " " .. math.floor(y-1) .. " " .. math.floor(z) .. " "
                else
                    input = input .. character
                end
            end
            local x,y = term.getCursorPos()
            term.setCursorPos(1,y)
            printToScreen(input)
        end
    end
end

function getMessage()
    term.setBackgroundColor(colors.cyan)
    term.clear()
    while true do
        local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
        local globaltext = ""
        if channel == 6 then
            globaltext = "[G]"
        end
        if (channel == myNumber or channel == 6) and type(message) == "string" and not contains(ignoreChannel,replyChannel) then
            if message == "#ping" then
                modem.transmit(replyChannel,myNumber,"#active")-- (to,from,message)
            elseif string.sub(message,1,1) ~= "#" then -- ignore message
                if chatBook[replyChannel] == nil then
                    local x,y = term.getCursorPos()
                    while y >= iny do
                        term.setCursorPos(1,y)
                        term.clearLine()
                        y = y - 1
                    end
                    term.setTextColor(colors.gray)
                    print("> " .. replyChannel .. globaltext .. ":" .. message .. "\n")
                else
                    local x,y = term.getCursorPos()
                    while y >= iny do
                        term.setCursorPos(1,y)
                        term.clearLine()
                        y = y - 1
                    end
                    term.setTextColor(chatBook[replyChannel][2])
                    term.write("> " .. chatBook[replyChannel][1] .. globaltext)
                    term.setTextColor(colors.gray)
                    print(":" .. message .. "\n")
                end
                term.setTextColor(colors.white)
                inx,iny = term.getCursorPos()
                printToScreen(input)
            end
        end
    end
end

function sendMessage()
    active = false
    while true do
        term.write("> ")
        term.setCursorBlink(true)
        -- local toSentMessage = read()
        readInputToggle = true
        readKey()
        print("")
        inx,iny = term.getCursorPos()
        readInputToggle = false
        local sentToNumber = 6
        if string.sub(input,1,1) == "@" then
            local call = ""
            for i = 1, #input do
                if string.sub(input,i,i) == " " then
                    break
                end
                call = call .. string.sub(input,i,i)
            end
            -- Get the Id of sender
            modem.transmit(3,myNumber,"#getId" .. call)
            while true do
                local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
                if message == "#setId" and channel == myNumber then
                    sentToNumber = replyChannel
                    if sentToNumber == 6 then
                        term.setTextColor(colors.red)
                        print("Invalid tag\n")
                        inx,iny = term.getCursorPos()
                        term.setTextColor(colors.white)
                    else
                        parallel.waitForAny(function() ping(sentToNumber) end, function() pingTimer(sentToNumber) end)
                        if active then
                            modem.transmit(sentToNumber,myNumber,input)
                        end
                    end
                    break
                end
            end

        elseif input == "" then
        elseif input == "/exit" then
            term.setBackgroundColor(colors.black)
            term.clear()
            term.setCursorPos(1,1)
            return
        else
            modem.transmit(sentToNumber,myNumber,input)
        end
        previnput = input
        input = ""
    end
end

----------------------------------Main--------------------------------------------
modem = peripheral.find("modem") or error("No modem attached", 0)
myNumber = os.getComputerID()
input = ""
previnput = ""
readInputToggle = true
version = 42
modem.open(myNumber)
modem.open(6)
chatBook = {
    [3] = {"Home",colors.red},
    [8] = {"Rayn",colors.blue},
    [10] = {"Fenrir",colors.orange},
    [13] = {"Rae",colors.pink}
}
ignoreChannel = {65534}
currentPos = 1
monitor = peripheral.find("monitor")  --Check if monitor is present
if monitor ~= nil then
    term.redirect(monitor)
end
term.setCursorPos(1,1)
inx, iny = term.getCursorPos()
parallel.waitForAny(function() ping(3) end, function() pingTimer(3) end)
parallel.waitForAny(getMessage,sendMessage,readInput)