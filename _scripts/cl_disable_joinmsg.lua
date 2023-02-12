hook.Add("ChatText", "luctus_disablejoinmsg", function(index, name, text, type)
    if type == "joinleave" then
        return true
    end
end)
