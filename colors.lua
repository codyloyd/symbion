-- http://pixeljoint.com/forum/forum_posts.asp?TID=12795
-- 20  12  0.109  - black
--  0.265  0.140  0.203  - plum
--  0.187  0.203 109  - midnight
--  78  0.289  78  - iron
-- 0.519  0.296  0.187  - earth
--  0.203 0.394  0.140  - moss
-- 0.812  70  72  - berry
-- 117 113  97  - olive

--  89 0.488 0.804  - cornflower
-- 0.820 0.488  44  - ocher
-- 0.519 149 161  - slate
-- 109 170  44  - leaf
-- 0.820 170 153  - peach
-- 109 194 202  - sky
-- 218 212  94  - maize
-- 222 238 214  - peppermint
Colors = {
  darkBlack = {0,0,0},
  black = {0.078,0.046,0.109},
  lightBlack = {0.148,0.106,0.199},

  white = {0.867,0.929,0.835},
  pureWhite = {1,1,1},

  lightGray = {0.519,0.582,0.628},
  gray = {0.457,0.441,0.378},
  darkGray = {0.304,0.289,0.304},

  lightBrown = {0.820,0.644,0.597},
  brown = {0.519,0.296,0.187},
  darkBrown = {0.336,0.227,.166},

  red = {0.812,0.273,0.293},

  orange = {0.820,0.488,0.171},

  yellow = {0.851,0.841,0.367},

  lightGreen = {0.525,0.744,0.271},
  green = {0.425,0.644,0.171},
  darkGreen = {0.203,0.394,0.140},

  lightBlue = {0.425,0.757,0.789},
  blue = {0.347,0.488,0.804},
  darkBlue = {0.187,0.203,0.425},

  darkPurple = {0.265,0.140,0.203},
}

function Colors.vary(c, v)
  variation = tinyRandomNumber(v)
  return {c[1]+variation,c[2]+variation,c[3]+variation}
end

function tinyRandomNumber(v)
  return math.random(v*-1,v)/255
end

function Colors.addAlpha(c, a)
  return {c[1],c[2],c[3],a}
end
