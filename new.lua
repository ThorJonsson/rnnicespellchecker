
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
                    s = { string.byte( s, 1, s_len ) }
                end

                if type( t ) == "string" then
                   t = { string.byte( t, 1, t_len ) }
                end
                -- initialize delete and insert vectors
                del = {}
                ins = {}
                eq = 0
                for i=1, t_len do -- Here we go through the letters of the correct word
                    specialChar == false
                        print('s:'..charVec(s))
                    if s[i]==t[i] then 
                       del[i] = string.byte('*')
                       ins[i] = string.byte('*')
                       print('I  '..string.char(del[i]))
                       print(string.char(ins[i]))
                    else
                       if eq == 0 then
                          j = i
                       end
                    
                       -- When we see an inconsistency in spelling we start looping through
                       -- the longer word. By assumption s is the longer word.
                       while s[j] ~= t[i] and s_len - j > t_len-1 do
                            -- we fill the delete vector with inconsistent char's from the incorrect word
                            -- the insert vector will be filled with the char's that we need from the correct word
                            -- By assumption s is the word which we are correcting
                            if s[j] == 195 then
                                del[j] = 195
                                del[j+1] = s[j+1]
                                j = j+1 -- I don't want to increase i as it is not 195
                                specialChar = true
                            else
                            
                                del[j] = s[j]
                                print('II  '..string.char(del[j]))
                                j = j+1
                            end
                       end

                       -- if we have not reached the end of the word we must have found a match
                       if s[j] == t[i] then
                            del[j] = string.byte('*')
                            ins[i] = string.byte('*')
                            print('III  '..string.char(del[j]))
                            print(string.char(ins[i]))
                       else
                            del[j] = s[j]
                            ins[i] = t[i]
                            print('IV  '..string.char(del[j]))
                            print(string.char(ins[i]))
                           
                       end
                       eq = 1
                       j = j+1
                    end
                end
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
