function ExplainSpelling(m)
        for k=2, #m do
            --m[k][1] is the wrong word
            --m[k][2] is the correct word
           if #m[k][1] > #m[k][2] then
                s = m[k][1] --longer word  
                t = m[k][2]
           else 
                s = m[k][2]
                t = m[k][1]
           end
                local s_len, t_len = #s, #t -- Calculate the sizes of the strings

                --Convert string arguments to arrays of ints
                if type( s ) == "string" then
                    sTab = { string.byte( s, 1, s_len ) }
                end

                if type( t ) == "string" then
                   tTab = { string.byte( t, 1, t_len ) }
                end
                -- initialize delete and insert vectors
                del = {}
                ins = {}
                SpecialCharNum = 0
                start = true
                for i=1, t_len do -- Here we go through the letters of the correct word
                  --  specialChar == false
                        print('s:'..charVec(s))
                   if sTab[i]==t[i] then 
                       del[i] = string.byte('*')
                       ins[i] = string.byte('*')
                       print('I  '..string.char(del[i])..'    '..i)
                       print(string.char(ins[i])..'  i:  '..i.. '  j:  '..j)
                       i = i+1
                    else
                        if start == true then
                            j =i
                            start=false
                        end
                       -- When we see an inconsistency in spelling we start looping through
                       -- the longer word. By assumption s is the longer word.
                       while sTab[j] ~= tTab[i] and s_len - j- SpecialCharNum > t_len-1 do
                            -- we fill the delete vector with inconsistent char's from the incorrect word
                            -- the insert vector will be filled with the char's that we need from the correct word
                            -- By assumption s is the word which we are correcting
                            print('skrýtið')
                            if s[j] == 195 then
                                del[j] = 195
                                del[j+1] = s[j+1]
                                j = j+1 -- I don't want to increase i as it is not 195
                                SpecialCharNum = NumSpecChar(string.sub(s,
                                print('VI'..string.char(del[j-1])..string.char(del[j])..'  j  '..j..'  i  '..i)
                                print(s_len..j..t_len)
                            else
                            
                                del[j] = s[j]
                                print('II  '..string.char(del[j])..'  j  '..j..'  i  '..i)
                                j = j+1
                           end
                       end

                       -- if we have not reached the end of the word we must have found a match
                       if s[j] == t[i] then
                            del[j] = string.byte('*')
                            ins[i] = string.byte('*')
                            print('III  '..string.char(del[j])..'  j:  '..j..'  i:  '..i)
                            print(string.char(ins[i])..'    '..i..'  j  '..j)
                       else
                            if s[j] == 195 then
                               del[j] = s[j]
                               del[j+1] = s[j+1]
                               j = j+1
                            else
                               del[j] = s[j]
                            end
                            if t[i] == 195 then
                                ins[i] = t[i]
                                ins[i+1] = t[i+1]
                                i = i+1
                            else
                                ins[i] = t[i]
                            end
                            
                            print('IV  '..string.char(del[j])..'  j  '..j..'  i  '..i)
                            print(string.char(ins[i])..'  i  '..i..'  j  '..j)
                           
                       end
                       j = j+1
                    end
                end
                       for i=1, #ins do print(string.char(ins[i])..'\n') end
                       for j=1, #del do print(string.char(del[j])..'\n') end
        if #m[k][1] > #m[k][2] then
                print(charVec(del))
                print(charVec(ins))
        else
                print(charVec(ins))
                print(charVec(del))
        end
     end
 end

 function charVec(m)
        str = string.char(m[1])

        for i=2,#m do 
                str = str .. string.char(m[i])
        end
        return str
 end

 function NumSpecChar(s)
         
         sTab = { string.byte( s, 1, #s ) }
         counter = 0
         
         for i=1,#s do
                 if s[i] == 195 then
                         counter = counter +1
                 end
          end
  end





