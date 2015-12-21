utf8 = require 'lua-utf8'
--Helper function
--Counts the length of a string with respect to icelandic letters
--The string has been decomposed into a table of char's
function strLen(sTab)
        iceLetterCount = 0
        for i=1,#sTab do
                if sTab[i] == 195 then
                    iceLetterCount = iceLetterCount +1
                end
        end
        return (#sTab - iceLetterCount)
end
-- Helper function that returns 1 if letter is not icelandic, otherwise 2
function iceChar(s)
        if s==195 then return 2 else return 1 end
end
-- Helper function which returns a string from a table of char's
function charVec(m)
        if type(m[1]) == "string" then
            str = m[1]
        else
            str = string.char(m[1])
        end
        
        for i=2,#m do 
            if type(m[i])=="string" and m[i] ~= '$' then
                str = str .. m[i]
            elseif m[i] ~= '$' then
                str = str .. string.char(m[i])
            end
        end
        return str
end

function ExplainData(filepath)
        require 'lfs'
        require 'csvigo'
        for file in lfs.dir(filepath) do
                m = csvigo.load{path=filepath..file,mode='raw'}
                CompStrings(m)
                
                csvigo.save{data=m,path=filepath..'NewRep'..file}
        end
end

function utf8CompStrings(m)
       l = 2
       -- We go through the whole table starting at line 2
       while l <= #m do
             if utf8.len(m[l][1])==0 or m[l][1] == nil and string.len(m[l][2])==0 or m[l][2] == nil then 
                table.insert(m[l],'')
                table.insert(m[l],'')
             else 
                -- The word as it was typed is in column 1
                -- The correction is in column 2
                wrong = m[l][1]
                correct = m[l][2]
                -- The code is symmetric with respect to which word has more characters
                if utf8.len(correct) > utf8.len(wrong) then
                        longerW = correct
                        shorterW = wrong
                else 
                        longerW = wrong
                        shorterW = correct
                end
                compareStrings(longerW,shorterW)
                if strLen(correct) >= strLen(wrong) then

                 print(m[l],shorterVec)
                 print(m[l],longerVec)
                else
                 print(m[l],longerVec)
                 print(m[l],shorterVec)
                end
             end
            l = l+1
         end
end

function compareStrings(longerW,shorterW) 
                local dbg = require("debugger.lua/debugger")
                -- Now we iterate through the chars
                i = 1
                lastPos = 0
                startPos = 1
                shorterVec = {}
                for j=1, utf8.len(shorterW) do 
                        shorterVec[j] = ','
                end

                longerVec = {}
                for j=1, utf8.len(longerW) do
                        longerVec[j] = utf8.sub(longerW,j,j)
                end
                k = 0
                -- Go through all the characters in the shorterW
                -- The objective is to obtain 
                while i <= utf8.len(shorterW) do  
                    -- We get the currchar
                    currChar = utf8.sub(shorterW,i,i)
                    if currChar == '%' then currChar = '%%' end
                    if currChar == '(' then currChar = '%(' end
                    if currChar == '[' then currChar = '%[' end
                    
                    lookUpStr = utf8.sub(longerW,i,utf8.len(longerW))
                        
                    startPos = utf8.find(lookUpStr,currChar)
                    if startPos == nil then
                        shorterVec[i] = currChar
                        lastPos = lastPos +1
                    else
                        lastPos = startPos + lastPos
                        -- We record the last position
                        shorterVec[i] = ','
                        longerVec[lastPos] = ','
                    end
                    i = i+1
                end
      print(shorterVec)
      print(longerVec)
                        
end

function captureSeq(longerW, shorterW)
        i = 1
        lastPos = 0
        startPos = 1
        shorterVec = {}
        longerVec = {}
        charPos = {}
        -- Go through all the characters in the shorter word
        sLength = utf8.len(shorterW)
        -- initially the string to be searched is all of the longerw
        -- We will later break up the string to prevent us from getting confused
        -- by repeated characters
        searchStr = longerW
        for i = 1, sLength do
                -- Captures char i from shorterW
                currChar = utf8.sub(shorterW,i,i)
                -- look for currchar in the strig
                charPos[i] = utf8.find(searchStr, currChar)
                searchStr = utf8.gsub(searchStr, currChar,'*',1) --1 refers to the number of substitutions made
                -- We only want to substitute for the position we have recorded
        end
        print(charPos)
        print(searchStr)
        return charPos
end                 
-- function that looks for the longest sequence
function longestSeq(charPos)

end
-- Taken from Rosetta code
-- Some basic dynamic programming that we should take a better look at later                     
function buildLIS(seq)
    local dbg = require("debugger.lua/debugger")
    piles = { { {table.remove(seq, 1), nil} } }
    while #seq>0 do
        dbg()
        x=table.remove(seq, 1)
        for j=1,#piles do
            if piles[j][#piles[j]][1]>x then
                table.insert(piles[j], {x, (piles[j-1] and #piles[j-1])})
                break
            elseif j==#piles then
                table.insert(piles, {{x, #piles[j]}})
            end
        end
    end
    t={}
    table.insert(t, piles[#piles][1][1])
    p=piles[#piles][1][2]
    for i=#piles-1,1,-1 do
        table.insert(t, piles[i][p][1])
        p=piles[i][p][2]
    end
    table.sort(t)
    print(unpack(t))
end                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
function CompStrings(m)
        local utf8 = require 'lua-utf8'
        l =2
         while l <= #m do
             if string.len(m[l][1])==0 or m[l][1] == nil and string.len(m[l][2])==0 or m[l][2] == nil then 
                     table.insert(m[l],'')
                     table.insert(m[l],'')
             
             else 
                 wrong = m[l][1] 
                 correct = m[l][2]
                 
                 --Convert string arguments to arrays of ints
                 if type( wrong ) == "string" then
                     sTab = { string.byte( wrong, 1, #wrong ) }
                 end

                 if type( correct ) == "string" then
                    tTab = { string.byte( correct, 1, #correct ) }
                 end
                 if strLen(correct) <= strLen(wrong) then
                         LongerW = wrong
                         LongerWTab = sTab
                         ShorterW = correct
                         ShorterWTab = tTab
                 else
                         LongerW = correct
                         LongerWTab = tTab
                         ShorterW = wrong
                         ShorterWTab = sTab
                 end
                 longerCorr = LongerWTab
                 shorterCorr = {}
                 lastPos = 0
                 startPos = 1
                 n = strLen(ShorterW)
                 k = 1
                 j = 0
                 i = 1
                 sumj = 0
                 -- We must go through each byt in shorterW
                 while i <= #ShorterWTab do
                     -- k will run through all replacements so it will go from 1 to n
                     if ShorterWTab[i] == 195 then
                             j = 1
                             sumj = sumj + j
                     else
                             j = 0 
                     end
                     -- always a single char, we need j=i+1 if it is icelandic
                     -- if it is icelandic then necessarily ShorterWTab[i] == 195
                     -- consequently we need to jump over the next bit
                     currChar = string.sub(ShorterW,i,i+j)
                     -- now we look for this char in our string
                     if currChar == '%' then currChar = '%%' end
                     if currChar == '(' then currChar = '%(' end
                     if currChar == '[' then currChar = '%[' end
                     startPos = utf8.find(utf8.sub(LongerW,lastPos+1,#LongerW),currChar)
                     -- if startPos is nil then our char can not be found in the longer word
                     if startPos == nil then
                             shorterCorr[k] = currChar
                     -- if the letter is icelandic j = 1 and we jump over the extra bytes from the unicode char
                             k = k + 1
                     else
                         startPos = startPos + lastPos
                     -- if the letter is found we simple put an asterisk to confirm happiness
                             shorterCorr[k] = ' '
                     -- if we find the startPos we must make sure that the longerCorr indices below that one and the lastpos contain proper letters
                             longerCorr[startPos] = ' '
                             if j>0 then 
                                 longerCorr[startPos+j] = '$' 
                             end
                             for r=1,startPos do
                             end
                             lastPos = startPos+j
                             k = k+ 1
                     end

                     i = i+j+1
                     -- if it is not nil then we shall put * in the longercorr vector for the position that corresponds to it,
                     -- and * as well in the shortercorr vector.
                     -- Then we will look to see whether it the position in front of it has a star or not
                     -- So we need to keep track of the last position
                     

                end
                if strLen(correct) >= strLen(wrong) then

                 table.insert(m[l],charVec(shorterCorr))
                 table.insert(m[l],charVec(longerCorr))
                else
                 table.insert(m[l],charVec(longerCorr))
                 table.insert(m[l],charVec(shorterCorr))
                end
             end
            l = l+1
         end
end

        
