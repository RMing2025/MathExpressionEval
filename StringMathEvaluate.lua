--@ BeginMethod
--@ MethodExecSpace=All
number Evaluate(any ifade)
{
local i, j
    -- 處理括號的遞迴計算
    i = 1
    while (i < #ifade) do
        if (ifade[i] == "(") then 
            j = i + 1
            local p = 1  -- 括號計數器
            while (j < #ifade) do
                if (ifade[j] == "(") then p = p + 1 end
                if (ifade[j] == ")") then
                    p = p - 1
                    if (p == 0) then break end
                end
                j = j + 1 
            end
            -- 遞迴計算括號內的表達式
            ifade[i] = self:Eval({table.unpack(ifade, i + 1, j - 1)}) 
            -- 移除已處理的括號內容
            for y = 1, j - i do table.remove(ifade, i + 1) end
        else
            i = i + 1
        end
    end

    -- 定義運算符優先級和操作數位置
    local p = {"¹²³", "n", "u", "/*mb", "+-"}  -- 运算符优先级（从高到低）
    local s = {"L",   "R", "D", "D",    "D" }  -- 操作数位置：L=左，R=右，D=两侧
    local sonuc = "!gen"  -- 預設錯誤碼

    -- 按優先級處理運算符
    for pi = 1, #p do
        i = 1
        while (i <= #ifade) do
            local c = ifade[i]
            -- 錯誤檢查
            if (c == "!" or c == "(") then return "!par" end  -- 未匹配括號
            if (c == nil) then return "!uni" end              -- 未知錯誤
            sonuc = tonumber(c)
            local ff1, ff2 = string.find(p[pi], c)

            -- 如果找到符合的運算符
            if (ff1 ~= nil) then
                local n1 = tonumber(ifade[i - 1])
                local n2 = tonumber(ifade[i + 1])

                -- 操作數驗證
                if (s[pi] == "D" and n1 == nil) then
                    if (c == "+" or c == "-") then else return "!op1" end  -- 缺少左操作數
                end
                if (s[pi] == "D" and n2 == nil) then return "!op2" end   -- 缺少右操作數
                if (s[pi] == "L" and n1 == nil) then return "!op1" end
                if (s[pi] == "R" and n2 == nil) then return "!op2" end

                -- 執行具體運算
                if (c == "¹") then sonuc = n1 end              -- 恆等運算
                if (c == "²") then sonuc = n1 * n1 end         -- 平方
                if (c == "³") then sonuc = n1 * n1 * n1 end   -- 立方
                if (c == "n") then sonuc = n2 * (-1) end      -- 負號
                if (c == "u") then sonuc = n1 ^ n2 end         -- 次方
                if (c == "*") then sonuc = n1 * n2 end         -- 乘法
                if (c == "/") then
                    if (n2 ~= 0) then sonuc = n1 / n2 else return "!div" end  -- 除法
                end
                if (c == "+") then
                    if (n1 ~= nil) then sonuc = n1 + n2 else sonuc = n2; s[pi] = "R" end  -- 加法或正號
                end
                if (c == "-") then
                    if (n1 ~= nil) then sonuc = n1 - n2 else sonuc = (-1) * n2; s[pi] = "R" end  -- 減法或負號
                end
                if (c == "m") then
					if (n2 ~= 0) then sonuc = n1 % n2 else return "!div" end
				end        -- 取餘
                if (c == "b") then
                    if (n2 ~= 0) then sonuc = (n1 - (n1 % n2)) / n2 else return "!biv" end  -- 整除
                end

                -- 更新表達式表
                ifade[i] = sonuc
                -- 移除已處理的操作數
                if (s[pi] == "L") then table.remove(ifade, i - 1) end
                if (s[pi] == "R") then table.remove(ifade, i + 1) end
                if (s[pi] == "D") then
                    table.remove(ifade, i - 1)
                    table.remove(ifade, i)
                end
            else
                i = i + 1
            end
        end
    end
    return sonuc
}
--@ EndMethod

--@ BeginMethod
--@ MethodExecSpace=All
number MathExpressionEval(string s)
{

	local ifade = {}  -- 儲存解析後的 token
    local i = 1
    local t = 1
    local is_number_or_decimal_point = false  -- 是否為數字
    local onceki = false -- 前一個字符是否為數字
    
    -- 將字符串解析為 token 序列
    while (i <= string.len(s)) do
        local c = string.sub(s, i, i)
        local b = string.byte(c)
        -- 判斷是否為數字
        if ((b >= 48 and b <= 57) or b == 46) then 
		is_number_or_decimal_point = true 
	    else 
		is_number_or_decimal_point = false 
	    end
        -- 合併連續數字
        if (is_number_or_decimal_point and onceki) then
            t = t - 1  -- 延續前一個 token
        else
            ifade[t] = ""  -- 新增 token
        end
        ifade[t] = ifade[t] .. c
        i = i + 1
        t = t + 1
        onceki = is_number_or_decimal_point
    end
	
    return self:Eval(ifade)
}
--@ EndMethod

