-- function printToMonitor(word,textcolor)
--     local width,height = term.getSize()
--     local x = 1
--     term.setTextColor(textcolor)
--     for i = 1, #word do
--         if x > width  then
--             currentPos = currentPos + 1
--             x = 5
--             term.setCursorPos(5,currentPos)
--         end
--         term.write(string.sub(word, i, i))
--         if string.sub(word, i, i) == ":" then
--             term.setTextColor(colors.white)
--         end
--         x = x + 1
--     end
-- end
modem = peripheral.find("modem") or error("modem not found",0)
myNumber = os.getComputerID()
version = tostring(42)
chatBook = {
    [3] = {"Home",colors.red},
    [8] = {"Rayn",colors.blue},
    [10] = {"Fenrir",colors.orange},
    [13] = {"Rae",colors.pink}
}
phoneBook = {
    ["Home"] = 3,
    ["Rayn"] = 8,
    ["Fenrir"] = 10,
    ["Rae"] = 13
}
modem.open(myNumber) -- local number
modem.open(6) -- global chat
--currentPos = 1
monitor = peripheral.find("monitor")  --Check if monitor is present
if monitor ~= nil then
    term.redirect(monitor)
end
term.setBackgroundColor(colors.cyan)
term.clear()
term.setCursorPos(1,1)
while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    local globaltext = ""
    if channel == 6 then
        globaltext = "[G]"
    end
    print("Rouge",channel,":",message)
    if channel == myNumber or channel == 6 and type(message) == "string"  then
        if string.match(message,"#ping") and channel == myNumber then
            if #message > 5 then
                local getVersion = string.sub(message,6)
                print("getversion -",getVersion," from",replyChannel,"message -",message)
                if getVersion == version then
                    modem.transmit(replyChannel,myNumber,"#active")
                else
                    modem.transmit(replyChannel,myNumber,"#update")
                end
            else
                modem.transmit(replyChannel,myNumber,"#active")-- (to,from,message)
            end
        elseif string.match(message,"#getId") and channel == myNumber then
            local sendToPerson = string.sub(message,string.find(message,"@") + 1)
            print("Got request for ID:",sendToPerson)
            if phoneBook[sendToPerson] then
                modem.transmit(replyChannel,phoneBook[sendToPerson],"#setId")
            else
                modem.transmit(replyChannel,6,"#setId")
            end
        elseif string.sub(message,1,1) ~= "#" then
            -- term.setCursorPos(1,currentPos)
            if chatBook[replyChannel] == nil then
                print(replyChannel .. globaltext .. ":" .. message .. "\n")
                --printToMonitor(replyChannel .. globaltext .. ":" .. message,colors.gray)
            else
                term.setTextColor(chatBook[replyChannel][2])
                write(chatBook[replyChannel][1] .. globaltext)
                term.setTextColor(colors.gray)
                print(":" .. message .. "\n")
                --printToMonitor(phoneBook[replyChannel][1] .. globaltext .. ":" .. message,phoneBook[replyChannel][2])
            end
            --currentPos = currentPos + 2
        end
    end
end
