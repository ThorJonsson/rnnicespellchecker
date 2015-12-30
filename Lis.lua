-- Thorsteinn Hjortur Jonsson 20/12/15
-- Find the longest increasing subsequence in a given sequence [LIS]
-- In Lua

-- Implement a set in lua
function Set(tab)
        local set = {}
        for _, i in ipairs(tab) do
                set[i] = true
        end
        return set
end

-- In this function we assume data has been loaded to m
function ObtainWrongInstances(m)
        a = {}
        j = 1
        for i=1,#m do
                if m[i][1] ~= m[i][2] then
                        a[j] = {}
                        a[j][1] = m[i][1]
                        a[j][2] = m[i][2]
                        j=j+1
                end
        end
        return a
end

-- This function performs the representation on all words in the csv table
function ExplainData(m)
        local csvigo = require 'csvigo'
        filepath = '/home/thj92/Haust2015/Reiknigreind/char-rnn/'
      --m = csvigo.load{path=filepath..file,mode='raw'}
                -- We start at i=2 to leave the header
                for i=2,#m do
                      representSpelling(m[i])  
                end

                csvigo.save{data=m,path=filepath..'Jólaskrá'}
end
-- Okay, this is the game:
-- We want to compare strings. We want it to be done in a way such that we see spelling mistakes
-- what we are trying to do is to produce a way of highlighting in which way this could be done
-- I only want to see what the obvious way, we have determined that the longest increasing subsequence will do this.
-- We will look think of the corrected word as our target sequence
-- and the trial word as the input
-- It is clear that the longest running subsequence of same characters in the same order as the corrected word
-- will be the word which will bear the most resemblance to the target sequence
-- This is the idea: Make two vectors each corresponding to the original word and to the corrected word
-- Note that we will then have obtained a measure in lua
function representSpelling(tab)
       wrongW = tab[1]
       correctW = tab[2]
       utf8 = require('lua-utf8')
       --dbg = require('debugger.lua/debugger')
       -- If this is the case then we need to figure out which characters we have to insert by looking 
       -- at the shorter word, that is the target word. Thid reduces the time complexity a little
       local longerW = ''
       local shorterW = ''
       if utf8.len(wrongW) >= utf8.len(correctW) then
               longerW = wrongW
               shorterW = correctW
       else
               shorterW = wrongW
               longerW = correctW
       end
       charPos = {}
       -- Go through all the characters in the shorter word
       sLength = utf8.len(shorterW)
       lLength = utf8.len(longerW)
       -- Before: searchStr = longerW
       -- After: charPos = the positions of the char's that are found
       -- i.e. character which is found 
       -- This loop shuffles through the characters in the shorter word,
       -- looking for their positions in the longer word
       -- There are two possible scenarios possible:
       -- 1. char is not found
       -- 2. char is found
       -- In case of 1. we need to insert the char to get the target word
       -- so we make an insert vector which contains the position of these chars
       -- In case of 2. we insert * instead of the char
       -- The chars remaining are all the chars that are not found in the shorterword
       -- these chars should go to the delete vector
       -- There are some chars that may be found that should also go to the delete vector,
       -- so this is a subset of chars which pertain to case 2
       -- The chars that should be deleted from the ones found are the ones that are not 
       -- int the longest subsequence of the chars which pertain to case 2
       -- So what we do in this loop is that we record the positions of the chars that are found
       local instances = {}
       local k = 1
       local currInst = {}
       local currChar = ''
       local charPos = -99
       local lastPos = -99
       -- We need the longerV as well to catch repeated chars
       for i = 1, sLength do
               --dbg()
                -- captures char i from shorterW
               currChar = utf8.sub(shorterW,i,i)
               if currChar == '%' then currChar = '%%' end
               if currChar == '(' then currChar = '%(' end
               if currChar == '[' then currChar = '%[' end
               -- look for currchar in the string
               -- case 1. char is not found
               -- case 2. char is found
               charPos = utf8.find(longerW, currChar)
               -- We only want the charPositions
               -- in case of 1, they are not found so they should be inserted
               if charPos == nil then
                   -- Nothing to do!
                   -- note that this vector will not have the same length as shorterW
                   --table.insert(insertV,i) --These are positions from the
                   -- shorter word, characters that are in the shorter word
                   -- but not in the longer
               else -- in case of 2.
                   -- In case there are multiple instances of currChar in longerW we prefer
                   -- the one that will give us the lis, that is the least value of charpos
                   -- bigger than lastpos
                   local tmpPos = charPos
                   while charPos <= lastPos and utf8.find(longerW, currChar, charPos + 1) ~= nil do
                           tmpPos = charPos
                           charPos = utf8.find(longerW, currChar, charPos +1)
                   end
                   if charPos ~= nil then tmpPos = charPos end
                   currInst = {charPos, tmpPos}
                   table.insert(instances, currInst)
                   --table.insert(deleteV,tmpPos) -- We need it to prevent same numbers problem from lis
                   if charPos > lastPos then lastPos = charPos end
               end
               -- Since we are always shrinking the word we are looking for a position in we will never
               -- ever get repeated postions, this importantly means that we can only obtain strictly 
               -- increasing subsequences
               --longerW = utf8.sub(longerW,i+1,lLength) 
               -- what if charPos == nil? No worries because we are going through the shorterW
               -- that means insert iff letter not found
       end
       -- Now we need to find the longest increasing subsequence of char positions in deleteV
       -- The indices belonging to the longest increasing subsequence should not be deleted
       -- Let 
       --dbg()
       local noInsertV = {}
       local deleteV = {}
       local noDeleteV = {}
       for i=1,#instances do table.insert(deleteV,instances[i][2]) end
       local noDeleteV = lis(deleteV)
       l = 1
       for i=1,#instances do 
               -- char positions that are not in insertV will be printed as they should be inserted
               if noDeleteV[l] == instances[i][2] then 
                       table.insert(noInsertV,instances[i][1]) 
                       l = l+1
               end
       end
       -- þetta er snilld held ég
       -- Now we only keep the charPositions that are not in noDeleteV
       -- noDeleteV is a strictly increasing sequence of numbers
       -- So we will simply go through the old DeleteV and we can iterate through noDeleteV at the same time
       local deleteW = '[ '
       local l = 1
       -- We want to print all chars in instances that are not in noDeleteV
       for i=1,lLength do
               if i ~= 1 then deleteW = deleteW..' , ' end
               if i == noDeleteV[l] then -- fill the cell with emptiness
                       deleteW = deleteW..' '
                       l = l+1
               else 
                       deleteW = deleteW..utf8.sub(longerW,i,i)
               end
       end
       deleteW = deleteW..' ]'
       local insertW = '[ '
       l = 1
       -- We want to print all chars in instances that are not in noInsertV
       for i=1,sLength do
               if i ~= 1 then insertW = insertW..' , ' end
               if i == noInsertV[l] then -- fill the cell with emptiness
                       insertW = insertW..' '
                       l = l+1
               else
                       insertW = insertW..utf8.sub(shorterW,i,i)
               end
       end
       insertW = insertW..' ]'
       -- ShorterW is targetW and insertV describes what needs to be done for the targetW
       -- The problem is symmetric in the sense that if targetW is longer then we can simply
       -- switch insert for delete

       if utf8.len(wrongW) >= utf8.len(correctW) then
               table.insert(tab,deleteW) -- Here shorterW is correctW, the targetW.
               table.insert(tab,insertW)
       else
               table.insert(tab,insertW)
               table.insert(tab,deleteW)
       end

end


-- Go through each character in the shorter word and look for the first instance of it in the longer word
-- r
-- Then from these vectors we will construct a function that produces a delete vector and an addition vector
-- The delete vector will contain the letters needed to delete characters from the longer word to obtain the 
-- subsequence.
-- The insert vector will contain the letters needed to insert characters into the shorter word to obtain the subsequence
-- We will look for this vector in the following non-trivial way
-- We make a function which takes in both vectors

-- We are given a sequence which contains the first found position in each string
-- This is the game:
-- We want to get the longest increasing subseqence from a given sequence
-- For example given the sequence [0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15]
-- The longest subsequence is 0,2,6,9,11,15
-- 
-- A = 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
-- A[1] = 0
-- Case 1. There are no active lists, create one
-- 0. 
-- -----------------------------------------------------------
-- A = 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
-- A[2] = 8. Case 2. Clone and extend.
-- 0.
-- 0, 8.
-- -----------------------------------------------------------
-- A = 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
-- A[3] = 4. Case 3. Clone, extend and discard.
-- 0. 
-- 0, 4.
-- 0, 8. Discarded
-- -----------------------------------------------------------
-- A = 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
-- A[4] = 12. Case 2. Clone and extend.
-- 0.
-- 0, 4. 
-- 0, 4, 12.  
-- -----------------------------------------------------------
-- A = 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
-- A[5] = 2. Case 3. Clone, extend and discard
-- 0.
-- 0, 2.
-- 0, 4. Discarded
-- 0, 4, 12. 
-- -----------------------------------------------------------
-- A = 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
-- A[5] = 10. Case 3. Clone, extend and discard
-- 0.
-- 0, 2.
-- 0, 2, 10.
-- 0, 4, 12. Discarded          
-- -----------------------------------------------------------
-- A = 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
-- A[6] = 6. Case 3. Clone, extend and discard
-- 0
-- 0, 2.
-- 0, 2, 6.
-- 0, 2, 10. Discarded
-- -----------------------------------------------------------
-- A = 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
-- A[7] = 14. Case 2. Clone and extend
-- 0
-- 0, 2.
-- 0, 2, 6.
-- 0, 2, 6, 14.
-- -----------------------------------------------------------
-- A = 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
-- A[8] = 1. Case 3. Clone, extend and discard
-- 0
-- 0, 1.
-- 0, 2. Discarded
-- 0, 2, 6.
-- 0, 2, 6, 14.
-- -----------------------------------------------------------
-- A = 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
-- A[9] = 9. Case 3. Clone, extend and discard
-- 0
-- 0, 1.
-- 0, 2, 6.
-- 0, 2, 6, 9.
-- 0, 2, 6, 14. Discarded
-- -----------------------------------------------------------
-- A = 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
-- A[10] = 5. Case 3. Clone, extend and discard
-- 0
-- 0, 1.
-- 0, 1, 5. 
-- 0, 2, 6. Discarded
-- 0, 2, 6, 9.
-- -----------------------------------------------------------
-- A = 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
-- A[11] = 13. Case 2. Clone and extend
-- 0
-- 0, 1, 5. 
-- 0, 2, 6, 9.
-- 0, 2, 6, 9, 13. 
-- -----------------------------------------------------------
-- A = 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
-- A[12] = 3. Case 2??? Clone and extend.
-- 0
-- 0, 3.
-- 0, 1, 5. 
-- 0, 2, 6, 9.
-- 0, 2, 6, 9, 13.
-- -----------------------------------------------------------
-- A = 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
-- A[13] = 11. Case 3. Clone, extend and discard.
-- 0
-- 0, 3.
-- 0, 1, 5. 
-- 0, 2, 6, 9.
-- 0, 2, 6, 9, 11. 
-- 0, 2, 6, 9, 13. Discard
-- -----------------------------------------------------------
-- A = 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
-- A[14] = 7. Case 3. Clone, extend and discard.
-- 0
-- 0, 3.
-- 0, 1, 5. 
-- 0, 1, 5, 7.  
-- 0, 2, 6, 9. Discard
-- 0, 2, 6, 9, 11. 
-- -----------------------------------------------------------
-- A = 0,8,4,12,2,10,6,14,1,9,5,13,3,11,7,15
-- A[15] = 15. Case 2. Clone and extend.
-- 0
-- 0, 3.
-- 0, 1, 5. 
-- 0, 1, 5, 7.  
-- 0, 2, 6, 9, 11.
-- 0, 2, 6, 9, 11, 15 <----------------------------This is LIS.
-- Now we simply have to model this process.
function lis(seq)
    -- After processing seq[i] we have 
    -- Stores the index k of the smallest value seq[k] such that there is an
    -- increasing subsequence of length len ending at seq[k] on the range k <=1
    -- Note that len <= k <= i because len represents the length of the 
    -- increasing subsequence, and k represents the index of its termination.
    -- There can never be an increasing subsequence of length 13 ending 
    -- at index 11. k <= i by defintion
    local M = {}
    -- Stores the index of the predecessor of seq[k] in the longest increasing
    -- subsequence ending at seq[k]
    local P = {}

    local L = 1
    for i=1, #seq do
            -- Binary search for the largest positive j <= L
            -- such that seq[tailIndices[j]] < seq[i]
            local lo = 2 -- maybe change to one
            local hi = L
            while lo <= hi do
                   mid = math.ceil((lo+hi)/2)
                    if seq[M[mid]] < seq[i] then
                            lo = mid + 1
                    else
                            hi = mid - 1
                    end
            end
            -- After searching, lo is 1 greater than the length
            -- of the longest prefix of seq[i]
            local newL = lo
            -- The predecessor of seq[i] is the last index of the
            -- subsequence of length newL - 1
            P[i] = M[newL-1]
            M[newL] = i
            if newL > L then
                    -- If we found a subsequence longer than any we've
                    -- found yet, update L
                    L = newL
            end
          
      end
      -- Reconstruct the longest increasing subsequence
      S = {}
      k = M[L]
      i = L-1
      while i > 0 do
              S[i] = seq[k]
              k = P[k]
              i = i - 1
     end
     return S
end

