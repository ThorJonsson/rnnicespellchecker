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

function CompStrings(m)
        l =2
         while l <= #m do
             if string.len(m[l][1])==0 and string.len(m[l][2])==0 then 
                     table.insert(m[l],'')
                     table.insert(m[l],'')
                     l=l+1 
             
             end 
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
                  startPos = string.find(string.sub(LongerW,lastPos+1,#LongerW),currChar)
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
              l = l+1
         end
end

        
