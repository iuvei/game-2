--
-- Author: Anthony
-- Date: 2014-10-29 18:32:08
-- Filename: RC4.lua
--
-- RC4加密算法的Lua实现
-- 算法实现原理 http://zh.wikipedia.org/wiki/RC4

--根据密钥key进行初始化长度为256的S盒
local function KSA(key)
  local S = {} --长度为256的S盒

  --初始化为0~255不重复的数字
  for i = 0, 255 do
    S[i] = i
  end

  local key_length = string.len(key)
  local key_byte = {}
  for i = 1, key_length do
    key_byte[i-1] = string.byte(key, i, i)
  end

  local j = 0
  --根据密钥key打乱S盒
  for i = 0, 255 do
    j = (j + S[i] + key_byte[i % key_length]) % 256
    S[i], S[j] = S[j], S[i]
  end
  return S
end
--每收到一个字节，就进行while循环，循环中还改变了S盒
local function PRGA(S, text_len)
  local i = 0
  local j = 0
  local K = {}

  for n = 1, text_len do

    i = (i + 1) % 256
    j = (j + S[i]) % 256

    S[i], S[j] = S[j], S[i]
    K[n] = S[(S[i] + S[j]) % 256]
  end
  return K
end

--字符的异或操作
local function bxor(a, b)
  if a < b then
    a, b = b, a
  end
  local res = 0
  local shift = 1
  while a ~= 0 do
    r_a = a % 2
    r_b = b % 2

    res = shift * ((r_a + r_b == 1) and 1 or 0) + res
    shift = shift * 2

    a = math.modf(a / 2)
    b = math.modf(b / 2)
  end
  return res
end

--定位S盒中的一个元素，并与输入字节异或，得到K
local function XOR(S, text)
  local len = string.len(text)
  local c = nil
  local res = {}
  for i = 1, len do
    c = string.byte(text, i, i)
    res[i] = string.char(bxor(S[i], c))
  end
  return table.concat(res)
end

-- function RC4(key, text)
--   local text_len = string.len(text)

--   local S = KSA(key)
--   local K = PRGA(S, text_len)
--   return XOR(K, text)
-- end

return function (key, text)
  local text_len = string.len(text)

  local S = KSA(key)
  local K = PRGA(S, text_len)
  return XOR(K, text)
end