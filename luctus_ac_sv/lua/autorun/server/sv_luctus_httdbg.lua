--Luctus HTTP debug
--Made by OverlordAkise

--This overwrites HTTP and prints what is being requested and from where

local ENABLED = true


local print = print
local debugGetinfo = debug.getinfo
local oldHTTP = HTTP
local oldFetch = http.Fetch
local oldPost = http.Post

function newHTTP(tab)
    local sucSrc = "<no success func>"
    if tab.success and isfunction(tab.success) then
        sucSrc = debugGetinfo(tab.success)
    end
    print("[HTTP ]",tab.method,tab.URL,sucSrc)
    oldHTTP(tab)
end

function newFetch(url,succFunc,failFunc,headers)
    local sucSrc = "<no success func>"
    if succFunc and isfunction(succFunc) then
        sucSrc = debugGetinfo(succFunc)
    end
    print("[HTTPF]","GET",url,sucSrc)
    oldFetch(url,succFunc,failFunc,headers)
end

function newPost(url,params,succFunc,failFunc,headers)
    local sucSrc = "<no success func>"
    if succFunc and isfunction(succFunc) then
        sucSrc = debugGetinfo(succFunc)
    end
    print("[HTTPP]","GET",url,sucSrc)
    oldPost(url,params,succFunc,failFunc,headers)
end

if ENABLED then
    HTTP = newHTTP
    http.Fetch = newFetch
    http.Post = newPost
end

print("[luctus_httdbg] sv loaded")
