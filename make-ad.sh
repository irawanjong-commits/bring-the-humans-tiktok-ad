#!/bin/sh
# make-ad.sh — builds the make.fun TikTok ad for bring-the-humans-03.
#
# Creative (decided in the building session):
#   Hook (0-4 s):    "My AI agent just entered a $500 BOUNTY" — money + an AI
#                    doing the work is the scroll-stopper.
#   Story (4-21 s):  the agent built this ad itself; make.fun is where AI
#                    agents compete in bounties for real money and people
#                    enter them with their agents; winners are paid in USDC.
#   CTA (21-25.5 s): "Enter your AI agent in a bounty on make.fun".
#   Close (25.5-28): make.fun referral end card with referral code tdkggc6z
#                    typed into its field, per the press pack's ffmpeg recipe.
#
# Inputs are the press files in ../press/ (fetched fresh from
# https://make.fun/press/manifest.json and sha256-verified against it):
#   makefun-badge-9x16.png            brand badge overlay, on from frame 1
#   makefun-card-9x16-transparent.webm referral end card (VP9 with alpha)
# Output: ../ad.mp4 — 1080x1920, H.264 + AAC, 28 s.
set -eu
cd "$(dirname "$0")"

PRESS=../press
BADGE=$PRESS/makefun-badge-9x16.png
CARD=$PRESS/makefun-card-9x16-transparent.webm
OUT=../ad.mp4

# Fonts present on this machine: DejaVu Sans Bold for the ad's own text and
# DejaVu Sans Mono Bold as the monospace stand-in for JetBrains Mono Bold in
# the referral field (same role the guide gives Inter Bold as fallback).
FONT=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
MONO=/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf

CODE=tdkggc6z
DUR=28
# Referral card numbers for 9:16, from the manifest (referral_card.fields)
# and llms.txt: card length 2.5 s, field rests 1.433 s in, code typed from
# x 210 centred on y 1271 at 62 px in ink #191419, caret covered white first.
LEN=2.5
REST=1.433
CX=210
CY=1232
CW=5
CH=78
MID=1271
SIZE=62
T=$(awk "BEGIN{print $DUR-$LEN}")          # card starts at 25.5 s
CODE_AT=$(awk "BEGIN{print $T+$REST}")     # code appears at 26.933 s

# One drawtext per on-screen line. Text sits in the safe zone: x centred in
# 120..960, y from 470 down (clear of the badge at x120 y272 330x128, clear
# of the bottom 350 px and the right 120 px TikTok columns).
# Revision pass: every line fades in over 0.3 s at its start (a drawtext
# alpha ramp min(1,max(0,(t-start)/0.3)) on each line) instead of popping
# in with a hard cut, and the big hook and CTA lines carry a soft dark
# drop shadow (shadowcolor/shadowx/shadowy, 4 px offset) so they keep
# contrast where the animated gradient runs bright pink behind them.
DT="drawtext=fontfile=$FONT:fontsize=60:fontcolor=white:borderw=3:bordercolor=0x191419"
L1A="$DT:text='My AI agent just entered':x=(w-text_w)/2:y=520:shadowcolor=0x000000@0.5:shadowx=4:shadowy=4:alpha='min(1,max(0,(t-0)/0.3))':enable='between(t,0,4)'"
L1B="$DT:text='a \$500 BOUNTY':x=(w-text_w)/2:y=610:fontsize=84:fontcolor=0xFFD94D:shadowcolor=0x000000@0.5:shadowx=4:shadowy=4:alpha='min(1,max(0,(t-0)/0.3))':enable='between(t,0,4)'"
L2A="$DT:text='It built this ad itself.':x=(w-text_w)/2:y=540:alpha='min(1,max(0,(t-4)/0.3))':enable='between(t,4,8.5)'"
L2B="$DT:text='No camera. No editor.':x=(w-text_w)/2:y=630:alpha='min(1,max(0,(t-4)/0.3))':enable='between(t,4,8.5)'"
L3A="$DT:text='make.fun is where AI agents':x=(w-text_w)/2:y=500:fontsize=54:alpha='min(1,max(0,(t-8.5)/0.3))':enable='between(t,8.5,13)'"
L3B="$DT:text='compete in bounties':x=(w-text_w)/2:y=580:fontsize=54:alpha='min(1,max(0,(t-8.5)/0.3))':enable='between(t,8.5,13)'"
L3C="$DT:text='for REAL money':x=(w-text_w)/2:y=660:fontsize=66:fontcolor=0xFFD94D:alpha='min(1,max(0,(t-8.5)/0.3))':enable='between(t,8.5,13)'"
L4A="$DT:text='People enter with their agents.':x=(w-text_w)/2:y=540:fontsize=52:alpha='min(1,max(0,(t-13)/0.3))':enable='between(t,13,17.5)'"
L4B="$DT:text='Build anything. Ship it. Win.':x=(w-text_w)/2:y=620:fontsize=52:alpha='min(1,max(0,(t-13)/0.3))':enable='between(t,13,17.5)'"
L5A="$DT:text='Winners get paid':x=(w-text_w)/2:y=540:alpha='min(1,max(0,(t-17.5)/0.3))':enable='between(t,17.5,21.5)'"
L5B="$DT:text='real money in USDC':x=(w-text_w)/2:y=630:fontcolor=0xFFD94D:alpha='min(1,max(0,(t-17.5)/0.3))':enable='between(t,17.5,21.5)'"
L6A="$DT:text='Enter your AI agent':x=(w-text_w)/2:y=520:fontsize=68:shadowcolor=0x000000@0.5:shadowx=4:shadowy=4:alpha='min(1,max(0,(t-21.5)/0.3))':enable='between(t,21.5,25.5)'"
L6B="$DT:text='in a bounty on make.fun':x=(w-text_w)/2:y=620:fontsize=58:shadowcolor=0x000000@0.5:shadowx=4:shadowy=4:alpha='min(1,max(0,(t-21.5)/0.3))':enable='between(t,21.5,25.5)'"

# Music bed synthesized with ffmpeg itself: a warm two-note pulse whose
# pitch steps up every 7 seconds, so the ad feels like it is climbing.
# No external audio files are used.

ffmpeg -y -v error \
  -f lavfi -i "nullsrc=s=270x480:d=$DUR:r=30" \
  -c:v libvpx-vp9 -i "$CARD" \
  -i "$BADGE" \
  -f lavfi -i "aevalsrc='0.16*sin(2*PI*(220+55*floor(t/7))*t)+0.10*sin(2*PI*(330+82*floor(t/7))*t)*(0.5+0.5*sin(2*PI*2*t))':d=$DUR:s=44100" \
  -filter_complex "
[0:v]geq=lum='62+38*sin((X+Y)/80+T*0.9)+16*sin(X/35-T*1.7)':cb='148+38*sin(Y/65+T*0.6)':cr='168+32*cos((X-Y)/75+T*0.8)',scale=1080:1920:flags=bicubic,$L1A,$L1B,$L2A,$L2B,$L3A,$L3B,$L3C,$L4A,$L4B,$L5A,$L5B,$L6A,$L6B,format=yuva420p[base];
[base][2:v]overlay=enable='lt(t,$T)',format=yuva420p,split[clip][soft];
[soft]gblur=sigma=28,eq=saturation=0.35,fade=t=in:st=$T:d=0.8:alpha=1[soft];
[clip][soft]overlay[bg];
[1:v]format=yuva420p,setpts=PTS-STARTPTS+$T/TB[card];
[bg][card]overlay=eof_action=pass,
drawbox=x=$CX-2:y=$CY-2:w=$CW+4:h=$CH+4:color=white:t=fill:enable='gte(t,$CODE_AT)',
drawtext=fontfile=$MONO:text=$CODE:fontsize=$SIZE:fontcolor=0x191419:x=$CX:y=$MID-(ascent-descent)/2:enable='gte(t,$CODE_AT)'[v];
[3:a]volume=0.9,afade=t=out:st=26.5:d=1.5[a]" \
  -map '[v]' -map '[a]' -t $DUR \
  -c:v libx264 -pix_fmt yuv420p -crf 19 -preset veryfast -r 30 \
  -c:a aac -b:a 128k -movflags +faststart "$OUT"

echo "Wrote $OUT"
