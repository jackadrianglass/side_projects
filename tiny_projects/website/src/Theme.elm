module Theme exposing (..)

import Color exposing (rgb255)



-- todo: Get the light version as well https://rosepinetheme.com/palette/ingredients/
-- todo: Probably want to get these colors into a common Pallette type


theme =
    -- todo: How do I get fonts to be scaled appropriately for headings and content
    { base = rgb255 25 23 36
    , surface = rgb255 31 29 46
    , overlay = rgb255 38 35 58
    , muted = rgb255 110 106 134
    , subtle = rgb255 144 140 170
    , text = rgb255 224 222 244
    , love = rgb255 235 111 146
    , gold = rgb255 246 193 119
    , rose = rgb255 235 188 186
    , pine = rgb255 49 116 143
    , foam = rgb255 156 207 216
    , iris = rgb255 196 167 231
    , highlightLow = rgb255 33 32 46
    , highlightMed = rgb255 64 61 82
    , highlightHigh = rgb255 82 79 103
    }
